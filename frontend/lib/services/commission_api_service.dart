import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_config.dart';
import '../models/commission.dart';

class CommissionApiService {
  const CommissionApiService();

  Future<List<Commission>> fetchCommissions() async {
    final response = await http.get(Uri.parse('$apiBaseUrl/api/commissions'));
    if (response.statusCode != 200) {
      throw StateError('제작 의뢰 목록 조회 실패: ${response.statusCode}');
    }
    final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>? ?? const {};
    final commissions = data['commissions'];
    if (commissions is! List) return const [];
    return commissions
        .whereType<Map<String, dynamic>>()
        .map(Commission.fromJson)
        .toList();
  }

  Future<Commission> create({
    required String title,
    required String description,
    required String category,
    required int budget,
    String? desiredDate,
    String? referenceImageUrl,
  }) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/commissions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'description': description,
        'category': category,
        'budget': budget,
        'desiredDate': desiredDate,
        'referenceImageUrl': referenceImageUrl,
      }),
    );
    final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw StateError(body['message'] as String? ?? '제작 의뢰 등록 실패: ${response.statusCode}');
    }
    return Commission.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// POST /api/commissions/{id}/offers — 작가 제안 등록(역경매: 현재 최저가보다 낮아야 한다).
  /// 성공하면 갱신된 의뢰, 규칙 위반이면 서버 메시지를 담은 StateError 를 던진다.
  Future<Commission> placeOffer({
    required int commissionId,
    required String artistName,
    required int amount,
    String? message,
  }) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/commissions/$commissionId/offers'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'artistName': artistName,
        'amount': amount,
        'message': message ?? '',
      }),
    );
    final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw StateError(body['message'] as String? ?? '제안 등록에 실패했습니다');
    }
    return Commission.fromJson(body['data'] as Map<String, dynamic>);
  }
}
