import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_config.dart';
import '../models/home_feed.dart';

class HomeFeedApiService {
  const HomeFeedApiService();

  Future<HomeFeed> fetch({String query = '', String? category}) async {
    final params = <String, String>{
      if (query.trim().isNotEmpty) 'query': query.trim(),
      if (category != null && category != '추천') 'category': category,
    };
    final uri = Uri.parse('$apiBaseUrl/api/feed/home')
        .replace(queryParameters: params.isEmpty ? null : params);
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw StateError('홈 피드 조회 실패: ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return HomeFeed.fromJson(body['data'] as Map<String, dynamic>);
  }
}
