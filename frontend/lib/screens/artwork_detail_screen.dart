import 'package:flutter/material.dart';

import '../constants/dust_tokens.dart';
import 'package:flutter/services.dart';

import '../models/artwork_detail.dart';
import '../services/artwork_api_service.dart';
import '../services/chat_api_service.dart';
import 'artist_portfolio_screen.dart';
import 'chat_screen.dart';
import 'checkout_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _detailFuture = _api.fetchDetail(widget.artworkId);
  }

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }

  Future<void> _closeAuction() async {
    try {
      final updated = await _api.closeAuction(widget.artworkId);
      if (!mounted) return;
      setState(() => _detailFuture = Future.value(updated));
      _showMessage(updated.winnerName == null
          ? '경매가 유찰로 종료되었습니다'
          : '경매 마감! 낙찰자: ${updated.winnerName}');
    } catch (error) {
      _showMessage(error is StateError ? error.message : '경매 마감에 실패했습니다');
    }
  }

  void _openCheckout(ArtworkDetail detail, {int? priceOverride}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            CheckoutScreen(artwork: detail, priceOverride: priceOverride),
      ),
    );
  }

  Future<void> _placeBid() async {
    final amount = int.tryParse(_bidController.text.replaceAll(',', ''));
    if (amount == null) {
      _showMessage('입찰가를 숫자로 입력해주세요');
      return;
    }
    setState(() => _bidding = true);
    try {
      final updated = await _api.placeBid(widget.artworkId, amount);
      if (!mounted) return;
      setState(() => _detailFuture = Future.value(updated));
      _bidController.clear();
      _showMessage('입찰이 완료되었습니다');
    } catch (error) {
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
      backgroundColor: DustColors.bgCanvas,
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
                  onPressed: () => setState(
                      () => _detailFuture = _api.fetchDetail(widget.artworkId)),
                  child: const Text('다시 시도'),
                ),
              );
            }
            final detail = snapshot.data!;
            return Column(
              children: [
                _Header(title: detail.title),
                Expanded(child: _DetailBody(detail: detail)),
                if (detail.auction && !detail.auctionClosed)
                  _BidBar(
                    controller: _bidController,
                    bidding: _bidding,
                    minimumBid: (detail.currentBid ?? detail.price) +
                        detail.minBidIncrement,
                    onBid: _placeBid,
                    onClose: _closeAuction,
                  )
                else if (detail.auction && detail.winnerName == '나')
                  _BuyBar(
                    price: detail.currentBid ?? detail.price,
                    label: '낙찰가 결제하기',
                    onBuy: () => _openCheckout(detail,
                        priceOverride: detail.currentBid),
                  )
                else if (detail.auction)
                  const _ClosedBar()
                else
                  _BuyBar(
                    price: detail.price,
                    onBuy: () => _openCheckout(detail),
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
  const _DetailBody({required this.detail});

  final ArtworkDetail detail;

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
            style: const TextStyle(fontSize: 12, color: DustColors.textSecondary)),
        const SizedBox(height: 12),
        _PriceSection(detail: detail),
        const SizedBox(height: 16),
        const Divider(height: 1, color: DustColors.borderSoft),
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
        color: DustColors.bgSurface,
        border: Border.all(color: DustColors.borderSoft),
        borderRadius: BorderRadius.circular(6),
      ),
      child: imageUrl.isEmpty
          ? const Text('Image',
              style: TextStyle(fontSize: 11, color: DustColors.textSecondary))
          : Image.network(imageUrl, fit: BoxFit.cover),
    );
  }
}

class _PriceSection extends StatelessWidget {
  const _PriceSection({required this.detail});

  final ArtworkDetail detail;

  @override
  Widget build(BuildContext context) {
    if (!detail.auction) {
      return Text('₩${_formatPrice(detail.price)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
    }
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: DustColors.bgSurface,
        border: Border.all(color: DustColors.borderSoft),
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
                    style: TextStyle(fontSize: 11, color: DustColors.danger)),
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
                Text(detail.remainingTime!,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
      MapEntry('정품 인증', detail.certified ? 'QR 정품 인증 발급' : '미발급'),
    ];
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: DustColors.bgSurface,
        border: Border.all(color: DustColors.borderSoft),
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
                              fontSize: 11, color: DustColors.textSecondary)),
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

  /// 작가와 1:1 문의 방을 열고 채팅으로 들어간다.
  Future<void> _openInquiry(BuildContext context) async {
    final room = await ChatApiService.openDirectRoom(name);
    if (!context.mounted) return;
    if (room == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('작가에게 문의할 수 없어요. 잠시 후 다시 시도해주세요')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatScreen(
          roomId: room.chatRoomId,
          partnerNickname: room.opponentNickname,
          partnerProfileImageUrl: room.opponentProfileImageUrl,
        ),
      ),
    );
  }

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
        side: const BorderSide(color: DustColors.borderSoft),
        borderRadius: BorderRadius.circular(6),
      ),
      leading: const CircleAvatar(backgroundColor: DustColors.borderSoft),
      title: Text(name, style: const TextStyle(fontSize: 13)),
      subtitle: Text(introduction, style: const TextStyle(fontSize: 11)),
      trailing: OutlinedButton(
        onPressed: () => _openInquiry(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: DustColors.brandPrimary,
          side: const BorderSide(color: DustColors.brandPrimary),
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
                border: Border.all(color: DustColors.borderSoft),
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
                          fontSize: 11, color: DustColors.textSecondary)),
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
        border: Border(top: BorderSide(color: DustColors.borderSoft)),
      ),
      child: Row(
        children: [
          // 프로토타입 전용: 마감 스케줄러 대신 수동으로 경매를 종료한다.
          IconButton(
            onPressed: onClose,
            tooltip: '경매 마감 (데모)',
            icon: const Icon(Icons.timer_off_outlined,
                size: 20, color: DustColors.textSecondary),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: '최소 ₩${_formatPrice(minimumBid)}',
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
              backgroundColor: DustColors.brandPrimary,
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
  const _ClosedBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: DustColors.borderSoft)),
      ),
      child: const Text(
        '경매가 종료되었습니다',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, color: DustColors.textSecondary),
      ),
    );
  }
}

class _BuyBar extends StatelessWidget {
  const _BuyBar({required this.price, required this.onBuy, this.label = '구매하기'});

  final int price;
  final VoidCallback onBuy;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: DustColors.borderSoft)),
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
              backgroundColor: DustColors.brandPrimary,
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
