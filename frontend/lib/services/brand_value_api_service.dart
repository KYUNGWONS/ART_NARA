import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_config.dart';
import '../models/brand_value.dart';

class BrandValueApiService {
  const BrandValueApiService();

  Future<BrandValue> fetch() async {
    final response = await http.get(Uri.parse('$apiBaseUrl/api/brand/value'));
    if (response.statusCode != 200) {
      throw StateError('서비스 가치 소개 조회 실패: ${response.statusCode}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return BrandValue.fromJson(body['data'] as Map<String, dynamic>);
  }
}
