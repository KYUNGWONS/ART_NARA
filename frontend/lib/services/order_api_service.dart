import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_config.dart';
import 'api_headers.dart';
import '../models/order.dart';

class OrderApiService {
  const OrderApiService();

  /// 실 PG 사용 여부와 결제창용 클라이언트 키. 실패하면 mock 결제로 진행한다.
  Future<({bool enabled, String? clientKey})> fetchPaymentConfig() async {
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/api/payments/config'));
      if (response.statusCode != 200) return (enabled: false, clientKey: null);
      final body =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? const {};
      return (
        enabled: data['enabled'] as bool? ?? false,
        clientKey: data['clientKey'] as String?,
      );
    } catch (_) {
      return (enabled: false, clientKey: null);
    }
  }

  Future<Order> create({
    required int artworkId,
    required String paymentMethod,
    /// 토스 결제창을 거쳤을 때만 채운다. 서버가 이 값으로 승인을 호출한다.
    String? paymentKey,
    String? tossOrderId,
  }) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/orders'),
      headers: authJsonHeaders(),
      body: jsonEncode({
        'artworkId': artworkId,
        'paymentMethod': paymentMethod,
        if (paymentKey != null) 'paymentKey': paymentKey,
        if (tossOrderId != null) 'tossOrderId': tossOrderId,
      }),
    );
    final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw StateError(body['message'] as String? ?? '결제 실패: ${response.statusCode}');
    }
    return Order.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<List<Order>> fetchOrders() async {
    // 내 주문 내역이라 서버가 JWT 신원으로 스코프한다 — 인증 헤더 필수.
    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/orders'),
      headers: authOnlyHeaders(),
    );
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
