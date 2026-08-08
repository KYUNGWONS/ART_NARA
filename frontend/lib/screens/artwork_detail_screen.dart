import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../constants/api_config.dart';
import '../constants/art_tokens.dart';
import '../utils/image_url.dart';
import '../utils/artist_inquiry.dart';
import 'package:flutter/services.dart';

import '../models/artwork_detail.dart';
import '../widgets/auction_countdown.dart';
import '../widgets/won_input_formatter.dart';
import '../services/artwork_api_service.dart';
import '../services/order_api_service.dart';
import 'order_history_screen.dart';
import 'artist_portfolio_screen.dart';

class ArtworkDetailScreen extends StatefulWidget {
  const ArtworkDetailScreen({super.key, required this.artworkId});

  final int artworkId;

  @override
  State<ArtworkDetailScreen> createState() => _ArtworkDetailScreenState();
}

class _ArtworkDetailScreenState extends State<ArtworkDetailScreen> {
  final _api = const ArtworkApiService();
  final _bidController = TextEditingController();
  late Future<ArtworkDetail> _detailFuture;
  bool _bidding = false;
  bool _reserving = false;

  /// 경매 작품일 때만 연결한다(일반 판매 작품은 갱신할 게 없다).
  StompClient? _auctionClient;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final future = _api.fetchDetail(widget.artworkId);
    _detailFuture = future;
    // 진행 중인 경매면 남이 넣은 입찰도 바로 보이도록 구독한다.
    future.then((detail) {
      if (mounted && detail.auction && !detail.auctionClosed) {
        _connectAuction();
      }
    }).catchError((_) {/* 조회 실패는 FutureBuilder 가 화면에 표시한다 */});
  }

  void _connectAuction() {
    if (_auctionClient != null) return;
    _auctionClient = StompClient(
      config: StompConfig(
        url: websocketUrl,
        onConnect: (_) {
          debugPrint('[Auction] 구독 → /topic/auction/${widget.artworkId}');
          _auctionClient?.subscribe(
            destination: '/topic/auction/${widget.artworkId}',
            // 서버가 최신 현재가를 밀어주면 상세를 다시 읽는다. 입찰 내역·낙찰 여부까지
            // 서버 계산 결과를 그대로 쓰기 위해서다(클라이언트가 부분 갱신하지 않는다).
            callback: (frame) {
              debugPrint('[Auction] 현황 수신: ${frame.body}');
              _refreshFromBroadcast();
            },
          );
        },
        onWebSocketError: (dynamic e) =>
            debugPrint('[Auction] WebSocket 오류: $e'),
        reconnectDelay: const Duration(seconds: 5),
      ),
    )..activate();
  }

  Future<void> _refreshFromBroadcast() async {
    try {
      final updated = await _api.fetchDetail(widget.artworkId);
      if (!mounted) return;
      setState(() {
        _detailFuture = Future.value(updated);
      });
    } catch (error) {
      debugPrint('[Auction] 현황 갱신 실패: $error');
    }
  }

  @override
  void dispose() {
    _auctionClient?.deactivate();
    _bidController.dispose();
    super.dispose();
  }

  Future<void> _closeAuction() async {
    try {
      final updated = await _api.closeAuction(widget.artworkId);
      if (!mounted) return;
      // 블록 바디로 감싼다 — 화살표로 대입하면 setState 콜백이 Future 를 반환해
      // '비동기 작업' 으로 오인되어 예외가 난다(상태는 이미 바뀐 뒤라 화면만 갱신되고 실패로 보였다).
      setState(() {
        _detailFuture = Future.value(updated);
      });
      _showMessage(updated.winnerName == null
          ? '경매가 유찰로 종료되었습니다'
          : '경매 마감! 낙찰자: ${updated.winnerName}');
    } catch (error) {
      _showMessage(error is StateError ? error.message : '경매 마감에 실패했습니다');
    }
  }

  /// 예약한다. 직거래라 여기서 결제하지 않는다 —
  /// 만나서 작품을 주고받고 양쪽이 확인한 뒤에 주문 내역에서 결제한다.
  Future<void> _reserve(ArtworkDetail detail) async {
    if (_reserving) return;
    setState(() => _reserving = true);
    try {
      await const OrderApiService().reserve(artworkId: detail.id);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('예약되었어요', style: TextStyle(fontSize: 16)),
          content: Text(
            "'${detail.title}' 을(를) 예약했습니다.\n\n"
            '작가님과 만나 작품을 받은 뒤, 주문 내역에서 '
            "'받았어요' 를 누르면 결제할 수 있어요.",
            style: const TextStyle(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      setState(_load); // 예약 상태를 화면에 반영
    } catch (error) {
      _showMessage(error is StateError ? error.message : '예약에 실패했습니다');
    } finally {
      if (mounted) setState(() => _reserving = false);
    }
  }

  Future<void> _placeBid() async {
    final amount = WonInputFormatter.digitsOf(_bidController.text);
    if (amount == null) {
      _showMessage('입찰가를 숫자로 입력해주세요');
      return;
    }
    setState(() => _bidding = true);
    try {
      final updated = await _api.placeBid(widget.artworkId, amount);
      if (!mounted) return;
      setState(() {
        _detailFuture = Future.value(updated);
      });
      _bidController.clear();
      _showMessage('입찰이 완료되었습니다');
    } catch (error) {
      debugPrint('[Bid] 입찰 처리 실패: $error');
      _showMessage(error is StateError ? error.message : '입찰에 실패했습니다');
    } finally {
      if (mounted) setState(() => _bidding = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArtColors.bgCanvas,
      body: SafeArea(
        child: FutureBuilder<ArtworkDetail>(
          future: _detailFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: OutlinedButton(
                  onPressed: () => setState(_load),
                  child: const Text('다시 시도'),
                ),
              );
            }
            final detail = snapshot.data!;
            return Column(
              children: [
                _Header(title: detail.title),
                Expanded(
                  child: _DetailBody(
                    detail: detail,
                    // 카운트다운이 0이 되면 서버를 다시 조회해
                    // 마감 상태(낙찰자·결제 버튼)를 반영한다.
                    onAuctionExpired: () => setState(_load),
                  ),
                ),
                if (detail.sold)
                  const _ClosedBar(message: '판매 완료된 작품입니다')
                // 내 예약이면 결제까지 갈 길을 알려준다 — 같은 문구를 쓰면
                // 정작 예약한 본인에게 남이 채간 것처럼 읽힌다.
                else if (detail.reserved && detail.reservedByViewer)
                  _ReservedByMeBar(
                    onOpenOrders: () =>
                        Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (_) => const OrderHistoryScreen(),
                    )),
                  )
                else if (detail.reserved)
                  const _ClosedBar(message: '예약 중인 작품입니다')
                else if (detail.auction && !detail.auctionClosed)
                  _BidBar(
                    controller: _bidController,
                    bidding: _bidding,
                    minimumBid: (detail.currentBid ?? detail.price) +
                        detail.minBidIncrement,
                    onBid: _placeBid,
                    onClose: _closeAuction,
                  )
                // 낙찰자 판정은 서버가 로그인 신원으로 계산해 내려준다.
                else if (detail.auction && detail.wonByViewer)
                  _BuyBar(
                    price: detail.currentBid ?? detail.price,
                    label: '낙찰가로 예약하기',
                    onBuy: () => _reserve(detail),
                  )
                else if (detail.auction)
                  const _ClosedBar()
                else
                  _BuyBar(
                    price: detail.price,
                    onBuy: () => _reserve(detail),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.detail, this.onAuctionExpired});

  final ArtworkDetail detail;
  final VoidCallback? onAuctionExpired;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      children: [
        _ArtworkImage(imageUrl: detail.imageUrl),
        const SizedBox(height: 16),
        Text(detail.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('${detail.artistName} · ${detail.year}',
            style: const TextStyle(fontSize: 12, color: ArtColors.textSecondary)),
        const SizedBox(height: 12),
        _PriceSection(detail: detail, onAuctionExpired: onAuctionExpired),
        const SizedBox(height: 16),
        const Divider(height: 1, color: ArtColors.borderSoft),
        const SizedBox(height: 16),
        const Text('작품 설명',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(detail.description, style: const TextStyle(fontSize: 12, height: 1.6)),
        const SizedBox(height: 16),
        _InfoTable(detail: detail),
        const SizedBox(height: 16),
        _ArtistCard(name: detail.artistName, introduction: detail.artistIntroduction),
        if (detail.auction) ...[
          const SizedBox(height: 16),
          _BidHistorySection(bids: detail.bidHistory),
        ],
      ],
    );
  }
}

class _ArtworkImage extends StatelessWidget {
  const _ArtworkImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ArtColors.bgSurface,
        border: Border.all(color: ArtColors.borderSoft),
        borderRadius: BorderRadius.circular(6),
      ),
      child: imageUrl.isEmpty
          ? const Text('Image',
              style: TextStyle(fontSize: 11, color: ArtColors.textSecondary))
          : Image.network(resolveImageUrl(imageUrl), fit: BoxFit.cover),
    );
  }
}

class _PriceSection extends StatelessWidget {
  const _PriceSection({required this.detail, this.onAuctionExpired});

  final ArtworkDetail detail;
  final VoidCallback? onAuctionExpired;

  @override
  Widget build(BuildContext context) {
    if (!detail.auction) {
      return Text('₩${_formatPrice(detail.price)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
    }
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: ArtColors.bgSurface,
        border: Border.all(color: ArtColors.borderSoft),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('현재가', style: TextStyle(fontSize: 11)),
              const SizedBox(height: 4),
              Text('₩${_formatPrice(detail.currentBid ?? detail.price)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          if (detail.auctionClosed)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('경매 종료',
                    style: TextStyle(fontSize: 11, color: ArtColors.danger)),
                const SizedBox(height: 4),
                Text(
                  detail.winnerName == null
                      ? '유찰'
                      : '낙찰자 ${detail.winnerName}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            )
          else if (detail.remainingTime != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('남은 시간', style: TextStyle(fontSize: 11)),
                const SizedBox(height: 4),
                AuctionCountdown(
                  detail.remainingTime,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                  onExpired: onAuctionExpired,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _InfoTable extends StatelessWidget {
  const _InfoTable({required this.detail});

  final ArtworkDetail detail;

  @override
  Widget build(BuildContext context) {
    final rows = <MapEntry<String, String>>[
      MapEntry('재료', detail.medium),
      MapEntry('크기', detail.size),
      MapEntry('소유권 인증', detail.certified ? 'QR 소유권 인증 발급' : '미발급'),
    ];
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: ArtColors.bgSurface,
        border: Border.all(color: ArtColors.borderSoft),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: rows
            .map(
              (row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 72,
                      child: Text(row.key,
                          style: const TextStyle(
                              fontSize: 11, color: ArtColors.textSecondary)),
                    ),
                    Expanded(
                      child: Text(row.value, style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ArtistCard extends StatelessWidget {
  const _ArtistCard({required this.name, required this.introduction});

  final String name;
  final String introduction;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ArtistPortfolioScreen(artistName: name),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 13),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: ArtColors.borderSoft),
        borderRadius: BorderRadius.circular(6),
      ),
      leading: const CircleAvatar(backgroundColor: ArtColors.borderSoft),
      title: Text(name, style: const TextStyle(fontSize: 13)),
      subtitle: Text(introduction, style: const TextStyle(fontSize: 11)),
      trailing: OutlinedButton(
        onPressed: () => openArtistInquiry(context, name),
        style: OutlinedButton.styleFrom(
          foregroundColor: ArtColors.brandPrimary,
          side: const BorderSide(color: ArtColors.brandPrimary),
        ),
        child: const Text('문의하기'),
      ),
    );
  }
}

class _BidHistorySection extends StatelessWidget {
  const _BidHistorySection({required this.bids});

  final List<ArtworkBid> bids;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('입찰 내역',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (bids.isEmpty)
          const Text('아직 입찰 내역이 없습니다', style: TextStyle(fontSize: 12))
        else
          ...bids.map(
            (bid) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: ArtColors.borderSoft),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(bid.bidderName,
                        style: const TextStyle(fontSize: 12)),
                  ),
                  Text('₩${_formatPrice(bid.amount)}',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 12),
                  Text(bid.bidTime,
                      style: const TextStyle(
                          fontSize: 11, color: ArtColors.textSecondary)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _BidBar extends StatelessWidget {
  const _BidBar({
    required this.controller,
    required this.bidding,
    required this.minimumBid,
    required this.onBid,
    required this.onClose,
  });

  final TextEditingController controller;
  final bool bidding;
  final int minimumBid;
  final VoidCallback onBid;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: ArtColors.borderSoft)),
      ),
      child: Row(
        children: [
          // 프로토타입 전용: 마감 스케줄러 대신 수동으로 경매를 종료한다.
          IconButton(
            onPressed: onClose,
            tooltip: '경매 마감 (데모)',
            icon: const Icon(Icons.timer_off_outlined,
                size: 20, color: ArtColors.textSecondary),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              // 치는 동안 천단위 콤마가 붙는다. 앞의 ₩ 는 고정 접두라 입력값에 섞이지 않는다.
              inputFormatters: const [WonInputFormatter()],
              decoration: InputDecoration(
                prefixText: '₩ ',
                prefixStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ArtColors.textPrimary),
                hintText: '최소 ${_formatPrice(minimumBid)}',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: bidding ? null : onBid,
            style: FilledButton.styleFrom(
              backgroundColor: ArtColors.brandPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(bidding ? '입찰 중...' : '입찰하기'),
          ),
        ],
      ),
    );
  }
}

class _ClosedBar extends StatelessWidget {
  const _ClosedBar({this.message = '경매가 종료되었습니다'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: ArtColors.borderSoft)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, color: ArtColors.textSecondary),
      ),
    );
  }
}

/// 내가 예약해 둔 작품 — 만나서 받은 뒤 결제하는 자리로 안내한다.
class _ReservedByMeBar extends StatelessWidget {
  const _ReservedByMeBar({required this.onOpenOrders});

  final VoidCallback onOpenOrders;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: ArtColors.borderSoft)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text('내가 예약한 작품이에요',
                style: TextStyle(fontSize: 13, color: ArtColors.textSecondary)),
          ),
          OutlinedButton(
            onPressed: onOpenOrders,
            style: OutlinedButton.styleFrom(
              foregroundColor: ArtColors.brandPrimary,
              side: const BorderSide(color: ArtColors.brandPrimary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ArtRadius.full)),
            ),
            child: const Text('주문 내역'),
          ),
        ],
      ),
    );
  }
}

class _BuyBar extends StatelessWidget {
  const _BuyBar({required this.price, required this.onBuy, this.label = '예약하기'});

  final int price;
  final VoidCallback onBuy;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: ArtColors.borderSoft)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text('₩${_formatPrice(price)}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          FilledButton(
            onPressed: onBuy,
            style: FilledButton.styleFrom(
              backgroundColor: ArtColors.brandPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}

String _formatPrice(int value) {
  final text = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) buffer.write(',');
    buffer.write(text[i]);
  }
  return buffer.toString();
}
