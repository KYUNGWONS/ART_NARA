import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_config.dart';
import '../models/artwork_detail.dart';

class ArtworkApiService {
  const ArtworkApiService();

  Future<ArtworkDetail> fetchDetail(int artworkId) async {
    final response =
        await http.get(Uri.parse('$apiBaseUrl/api/artworks/$artworkId'));
    if (response.statusCode != 200) {
      throw StateError('작품 상세 조회 실패: ${response.statusCode}');
    }
    final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return ArtworkDetail.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<ArtworkDetail> placeBid(int artworkId, int amount) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/artworks/$artworkId/bids'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'amount': amount}),
    );
    final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw StateError(body['message'] as String? ?? '입찰 실패: ${response.statusCode}');
    }
    return ArtworkDetail.fromJson(body['data'] as Map<String, dynamic>);
  }
}
