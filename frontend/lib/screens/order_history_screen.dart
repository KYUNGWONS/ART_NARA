import 'package:flutter/material.dart';

import '../constants/art_tokens.dart';
import 'art_home_feed_screen.dart' show formatPrice;

import '../models/order.dart';
import '../services/order_api_service.dart';
import 'checkout_screen.dart';
import '../services/review_api_service.dart';

/// 주문 내역. [selling] 이면 내 작품에 걸린 거래(판매자 입장)를 보여준다.
class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key, this.selling = false});

  final bool selling;

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final _api = const OrderApiService();
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetch();
  }

  Future<List<Order>> _fetch() =>
      widget.selling ? _api.fetchSellingOrders() : _api.fetchOrders();

  Future<void> _reload() async {
    if (!mounted) return;
    setState(() {
      _ordersFuture = _fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArtColors.bgCanvas,
      appBar: AppBar(
        backgroundColor: ArtColors.bgCanvas,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.selling ? '내 작품 거래' : '주문 내역',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: OutlinedButton(
                onPressed: _reload,
                child: const Text('다시 시도'),
              ),
            );
          }
          final orders = snapshot.data ?? const <Order>[];
          if (orders.isEmpty) {
            return const Center(
              child: Text('아직 거래 내역이 없습니다', style: TextStyle(fontSize: 12)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            itemCount: orders.length,
            itemBuilder: (context, index) =>
                _OrderCard(order: orders[index], onChanged: _reload),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatefulWidget {
  const _OrderCard({required this.order, this.onChanged});

  final Order order;

  /// 확인·결제·취소로 상태가 바뀌면 목록을 다시 읽게 한다.
  final Future<void> Function()? onChanged;

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  // 리뷰 시트용. 시트가 닫히는 애니메이션 중에도 TextField 가 컨트롤러를 참조하므로
  // 시트 종료 시점에 dispose 하면 '_dependents.isEmpty' assertion 으로 죽는다(실측).
  // 화면이 사라질 때 State 가 정리한다.
  final TextEditingController _contentController = TextEditingController();

  /// 확인·결제·취소 요청 중 중복 탭 방지.
  bool _busy = false;

  Order get order => widget.order;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  /// 별점 + 후기 입력 시트. 성공/실패는 스낵바로 알린다.
  void _showReviewSheet(BuildContext context) {
    int rating = 5;
    _contentController.clear();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          // 키보드가 올라와도 입력창이 가려지지 않게
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(ArtSpacing.lg),
            decoration: const BoxDecoration(
              color: ArtColors.bgSurface,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(ArtRadius.lg)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('${order.artworkTitle} 리뷰',
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: ArtColors.textPrimary)),
                const SizedBox(height: ArtSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return IconButton(
                      onPressed: () => setSheetState(() => rating = i + 1),
                      icon: Icon(
                        i < rating
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 32,
                        color: ArtColors.brandPrimary,
                      ),
                    );
                  }),
                ),
                TextField(
                  controller: _contentController,
                  maxLines: 3,
                  maxLength: 1000,
                  decoration: InputDecoration(
                    hintText: '작품과 거래 경험을 남겨주세요',
                    hintStyle: const TextStyle(
                        fontSize: 14, color: ArtColors.textSecondary),
                    filled: true,
                    fillColor: ArtColors.bgSubtle,
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ArtRadius.sm),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(
                      fontSize: 14, color: ArtColors.textPrimary),
                ),
                const SizedBox(height: ArtSpacing.md),
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: () async {
                      final content = _contentController.text.trim();
                      if (content.isEmpty) return;
                      final error = await ReviewApiService.create(
                        artworkId: order.artworkId,
                        rating: rating,
                        content: content,
                      );
                      if (!sheetContext.mounted) return;
                      Navigator.pop(sheetContext);
                      if (!mounted) return;
                      ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(
                          content: Text(error ?? '리뷰가 등록되었어요')));
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: ArtColors.brandPrimary,
                      foregroundColor: ArtColors.textOnBrand,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ArtRadius.md),
                      ),
                    ),
                    child: const Text('등록하기',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 결제 전에는 소유권이 없다. 단계에 맞는 안내를 보여준다.
  String _ownershipLine() {
    if (order.cancelled) return '예약이 취소되었습니다';
    if (order.refunded) return '환불되어 디지털 소유권이 회수되었습니다';
    if (order.paid) return '디지털 소유권 ${order.certificateNo}';
    if (order.readyToPay) return '수령 확인 완료 — 결제하면 소유권이 발급됩니다';
    final mine = order.viewerIsSeller ? order.sellerConfirmed : order.buyerConfirmed;
    final other = order.viewerIsSeller ? order.buyerConfirmed : order.sellerConfirmed;
    if (mine && !other) return '상대의 확인을 기다리는 중입니다';
    return order.viewerIsSeller
        ? '만나서 전달한 뒤 확인해주세요'
        : '작가님과 만나 작품을 받은 뒤 확인해주세요';
  }

  /// 직거래 단계 버튼: 수령 확인 → (양쪽 끝나면) 결제. 결제 전에는 취소할 수 있다.
  Widget _tradeActions() {
    final canConfirm = order.needsMyConfirmation;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _busy ? null : _cancel,
          style: TextButton.styleFrom(
            foregroundColor: ArtColors.textSecondary,
            padding: const EdgeInsets.symmetric(horizontal: ArtSpacing.sm),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('예약 취소', style: TextStyle(fontSize: 12)),
        ),
        const SizedBox(width: ArtSpacing.xs),
        if (canConfirm)
          FilledButton(
            onPressed: _busy ? null : _confirmHandover,
            style: FilledButton.styleFrom(
              backgroundColor: ArtColors.brandPrimary,
              padding: const EdgeInsets.symmetric(
                  horizontal: ArtSpacing.md, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(order.viewerIsSeller ? '전달했어요' : '받았어요',
                style: const TextStyle(fontSize: 12)),
          )
        // 결제는 구매자만 한다.
        else if (order.readyToPay && !order.viewerIsSeller)
          FilledButton(
            onPressed: _busy ? null : _pay,
            style: FilledButton.styleFrom(
              backgroundColor: ArtColors.brandPrimary,
              padding: const EdgeInsets.symmetric(
                  horizontal: ArtSpacing.md, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('결제하기', style: TextStyle(fontSize: 12)),
          ),
      ],
    );
  }

  Future<void> _confirmHandover() async {
    setState(() => _busy = true);
    try {
      await const OrderApiService().confirmHandover(order.orderId);
      await widget.onChanged?.call();
    } catch (error) {
      _snack(error is StateError ? error.message : '수령 확인에 실패했습니다');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel() async {
    setState(() => _busy = true);
    try {
      await const OrderApiService().cancel(order.orderId);
      await widget.onChanged?.call();
    } catch (error) {
      _snack(error is StateError ? error.message : '예약 취소에 실패했습니다');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pay() async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => CheckoutScreen(
        orderId: order.orderId,
        artworkTitle: order.artworkTitle,
        price: order.amount,
      ),
    ));
    await widget.onChanged?.call();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        border: Border.all(color: ArtColors.borderSoft),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(order.artworkTitle,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ArtColors.successBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(order.status,
                    style: const TextStyle(
                        fontSize: 11, color: ArtColors.success)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('${order.artistName} · ${order.orderedDate}',
              style: const TextStyle(fontSize: 11, color: ArtColors.textSecondary)),
          const SizedBox(height: 4),
          Text('결제 금액 ₩${formatPrice(order.amount)}',
              style: const TextStyle(fontSize: 11, color: ArtColors.textSecondary)),
          const SizedBox(height: 4),
          Text(_ownershipLine(), style: const TextStyle(fontSize: 11)),
          const SizedBox(height: ArtSpacing.xs),
          if (!order.paid && !order.cancelled) _tradeActions(),
          // 결제하고 환불하지 않은 거래에만 리뷰를 쓸 수 있다(서버도 막는다).
          if (order.paid && !order.refunded)
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => _showReviewSheet(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ArtColors.brandPrimary,
                  side: const BorderSide(color: ArtColors.borderSoft),
                  padding: const EdgeInsets.symmetric(
                      horizontal: ArtSpacing.sm, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.star_border_rounded, size: 15),
                label: const Text('리뷰 쓰기', style: TextStyle(fontSize: 12)),
              ),
            ),
        ],
      ),
    );
  }
}
