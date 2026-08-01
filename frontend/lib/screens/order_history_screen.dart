import 'package:flutter/material.dart';

import '../constants/dust_tokens.dart';
import 'art_home_feed_screen.dart' show formatPrice;

import '../models/order.dart';
import '../services/order_api_service.dart';

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
        ],
      ),
    );
  }
}
