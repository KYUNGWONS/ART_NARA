import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_config.dart';
import '../models/settlement.dart';
import 'api_headers.dart';

class SettlementApiService {
  const SettlementApiService();

  /// 내 판매 정산. 대상은 서버가 JWT 신원으로 정하므로 인증 헤더가 필수다.
  Future<Settlement> fetchMySettlement() async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/settlements'),
      headers: authOnlyHeaders(),
    );
    if (response.statusCode != 200) {
      throw StateError('정산 조회 실패: ${response.statusCode}');
    }
    final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return Settlement.fromJson(body['data'] as Map<String, dynamic>);
  }
}
