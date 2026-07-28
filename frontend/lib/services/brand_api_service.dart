import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_config.dart';
import '../models/brand_intro.dart';

class BrandApiService {
  const BrandApiService();

  Future<BrandIntro> fetchIntro() async {
    final response = await http.get(Uri.parse('$apiBaseUrl/api/brand/intro'));
    if (response.statusCode != 200) {
      throw StateError('브랜드 소개 조회 실패: ${response.statusCode}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return BrandIntro.fromJson(body['data'] as Map<String, dynamic>);
  }
}
