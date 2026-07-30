import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_config.dart';
import '../models/order.dart';

class OrderApiService {
  const OrderApiService();

  Future<Order> create({
    required int artworkId,
    required String paymentMethod,
    required String receiverName,
    required String phone,
    required String deliveryAddress,
  }) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'artworkId': artworkId,
        'paymentMethod': paymentMethod,
        'receiverName': receiverName,
        'phone': phone,
        'deliveryAddress': deliveryAddress,
      }),
    );
    final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw StateError(body['message'] as String? ?? '결제 실패: ${response.statusCode}');
    }
    return Order.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<List<Order>> fetchOrders() async {
    final response = await http.get(Uri.parse('$apiBaseUrl/api/orders'));
    if (response.statusCode != 200) {
      throw StateError('주문 내역 조회 실패: ${response.statusCode}');
    }
    final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>? ?? const {};
    final orders = data['orders'];
    if (orders is! List) return const [];
    return orders.whereType<Map<String, dynamic>>().map(Order.fromJson).toList();
  }
}
