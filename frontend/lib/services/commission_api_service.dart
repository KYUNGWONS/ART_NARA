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
      }),
    );
    final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw StateError(body['message'] as String? ?? '제작 의뢰 등록 실패: ${response.statusCode}');
    }
    return Commission.fromJson(body['data'] as Map<String, dynamic>);
  }
}
