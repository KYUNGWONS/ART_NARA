import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_config.dart';
import 'api_headers.dart';
import '../models/order.dart';

class OrderApiService {
  const OrderApiService();

  /// 실 PG 사용 여부·결제창 키와 판매 수수료율. 실패하면 mock 결제로 진행한다.
  ///
  /// 수수료율은 서버 상수를 그대로 받는다 — 화면에 따로 적어두면 정산과 어긋난다
  /// (판매 등록 화면이 8% 라고 안내하는데 실제로는 10% 를 떼던 적이 있다).
  Future<({bool enabled, String? clientKey, int feeRatePercent})>
      fetchPaymentConfig() async {
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/api/payments/config'));
      if (response.statusCode != 200) return _paymentConfigFallback;
      final body =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? const {};
      return (
        enabled: data['enabled'] as bool? ?? false,
        clientKey: data['clientKey'] as String?,
        feeRatePercent: (data['feeRatePercent'] as num?)?.toInt() ??
            _paymentConfigFallback.feeRatePercent,
      );
    } catch (_) {
      return _paymentConfigFallback;
    }
  }

  /// 서버에 못 물었을 때 쓰는 값. 수수료율은 서버 기본값과 같게 둔다.
  static const _paymentConfigFallback =
      (enabled: false, clientKey: null, feeRatePercent: 10);

  /// 작품을 예약한다. 직거래라 결제는 만나서 수령을 확인한 뒤에 한다.
  Future<Order> reserve({required int artworkId}) async {
    return _post('$apiBaseUrl/api/orders', {'artworkId': artworkId},
        fallbackMessage: '예약 실패');
  }

  /// 수령 확인. 판매자면 '전달했어요', 구매자면 '받았어요' 로 기록된다.
  Future<Order> confirmHandover(int orderId) async {
    return _post('$apiBaseUrl/api/orders/$orderId/handover', null,
        fallbackMessage: '수령 확인 실패');
  }

  /// 결제. 양쪽 수령 확인이 끝난 뒤에만 열린다.
  Future<Order> pay({
    required int orderId,
    required String paymentMethod,
    /// 토스 결제창을 거쳤을 때만 채운다. 서버가 이 값으로 승인을 호출한다.
    String? paymentKey,
    String? tossOrderId,
  }) async {
    return _post('$apiBaseUrl/api/orders/$orderId/pay', {
      'paymentMethod': paymentMethod,
      if (paymentKey != null) 'paymentKey': paymentKey,
      if (tossOrderId != null) 'tossOrderId': tossOrderId,
    }, fallbackMessage: '결제 실패');
  }

  /// 결제 전 예약을 무른다. 작품은 다시 판매 중으로 돌아간다.
  Future<void> cancel(int orderId) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/orders/$orderId/cancel'),
      headers: authOnlyHeaders(),
    );
    if (response.statusCode != 200) {
      final body =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      throw StateError(body['message'] as String? ?? '예약 취소 실패');
    }
  }

  Future<Order> _post(String url, Map<String, dynamic>? payload,
      {required String fallbackMessage}) async {
    final response = await http.post(
      Uri.parse(url),
      headers: payload == null ? authOnlyHeaders() : authJsonHeaders(),
      body: payload == null ? null : jsonEncode(payload),
    );
    final body =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw StateError(
          body['message'] as String? ?? '$fallbackMessage: ${response.statusCode}');
    }
    return Order.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<List<Order>> fetchOrders() => _fetchList('$apiBaseUrl/api/orders');

  /// 내 작품에 걸린 거래(판매자 입장). '전달했어요' 를 누르려면 이 목록이 필요하다.
  Future<List<Order>> fetchSellingOrders() =>
      _fetchList('$apiBaseUrl/api/orders/selling');

  Future<List<Order>> _fetchList(String url) async {
    // 내 거래라 서버가 JWT 신원으로 스코프한다 — 인증 헤더 필수.
    final response = await http.get(Uri.parse(url), headers: authOnlyHeaders());
    if (response.statusCode != 200) {
      throw StateError('거래 내역 조회 실패: ${response.statusCode}');
    }
    final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>? ?? const {};
    final orders = data['orders'];
    if (orders is! List) return const [];
    return orders.whereType<Map<String, dynamic>>().map(Order.fromJson).toList();
  }
}
