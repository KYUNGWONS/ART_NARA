import 'package:flutter/material.dart';

import '../constants/dust_tokens.dart';
import 'art_home_feed_screen.dart' show formatPrice;

import '../models/order.dart';
import '../services/order_api_service.dart';
import '../services/review_api_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final _api = const OrderApiService();
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _api.fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DustColors.bgCanvas,
      appBar: AppBar(
        backgroundColor: DustColors.bgCanvas,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('주문 내역',
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
                onPressed: () =>
                    setState(() => _ordersFuture = _api.fetchOrders()),
                child: const Text('다시 시도'),
              ),
            );
          }
          final orders = snapshot.data ?? const <Order>[];
          if (orders.isEmpty) {
            return const Center(
              child: Text('아직 주문 내역이 없습니다', style: TextStyle(fontSize: 12)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            itemCount: orders.length,
            itemBuilder: (context, index) => _OrderCard(order: orders[index]),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  /// 별점 + 후기 입력 시트. 성공/실패는 스낵바로 알린다.
  void _showReviewSheet(BuildContext context) {
    int rating = 5;
    final contentController = TextEditingController();

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
            padding: const EdgeInsets.all(DustSpacing.lg),
            decoration: const BoxDecoration(
              color: DustColors.bgSurface,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(DustRadius.lg)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('${order.artworkTitle} 리뷰',
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: DustColors.textPrimary)),
                const SizedBox(height: DustSpacing.md),
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
                        color: DustColors.brandPrimary,
                      ),
                    );
                  }),
                ),
                TextField(
                  controller: contentController,
                  maxLines: 3,
                  maxLength: 1000,
                  decoration: InputDecoration(
                    hintText: '작품과 거래 경험을 남겨주세요',
                    hintStyle: const TextStyle(
                        fontSize: 14, color: DustColors.textSecondary),
                    filled: true,
                    fillColor: DustColors.bgSubtle,
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DustRadius.sm),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(
                      fontSize: 14, color: DustColors.textPrimary),
                ),
                const SizedBox(height: DustSpacing.md),
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: () async {
                      final content = contentController.text.trim();
                      if (content.isEmpty) return;
                      final error = await ReviewApiService.create(
                        artworkId: order.artworkId,
                        rating: rating,
                        content: content,
                      );
                      if (!sheetContext.mounted) return;
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(error ?? '리뷰가 등록되었어요')));
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: DustColors.brandPrimary,
                      foregroundColor: DustColors.textOnBrand,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DustRadius.md),
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
    ).then((_) => contentController.dispose());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        border: Border.all(color: DustColors.borderSoft),
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
                  color: DustColors.successBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(order.status,
                    style: const TextStyle(
                        fontSize: 11, color: DustColors.success)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('${order.artistName} · ${order.orderedDate}',
              style: const TextStyle(fontSize: 11, color: DustColors.textSecondary)),
          const SizedBox(height: 4),
          Text('결제 금액 ₩${formatPrice(order.amount)}',
              style: const TextStyle(fontSize: 11, color: DustColors.textSecondary)),
          const SizedBox(height: 4),
          Text('디지털 소유권 ${order.certificateNo}',
              style: const TextStyle(fontSize: 11)),
          const SizedBox(height: DustSpacing.xs),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () => _showReviewSheet(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: DustColors.brandPrimary,
                side: const BorderSide(color: DustColors.borderSoft),
                padding: const EdgeInsets.symmetric(
                    horizontal: DustSpacing.sm, vertical: 6),
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
