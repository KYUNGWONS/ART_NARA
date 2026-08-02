import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_config.dart';
import 'api_headers.dart';
import '../models/artwork_detail.dart';
import '../models/nearby_artwork.dart';

class ArtworkApiService {
  const ArtworkApiService();

  Future<List<NearbyArtwork>> fetchNearby({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse('$apiBaseUrl/api/artworks/nearby').replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      },
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw StateError('집 주변 작품 조회 실패: ${response.statusCode}');
    }
    final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>? ?? const {};
    final artworks = data['artworks'];
    if (artworks is! List) return const [];
    return artworks
        .whereType<Map<String, dynamic>>()
        .map(NearbyArtwork.fromJson)
        .toList();
  }

  Future<ArtworkDetail> fetchDetail(int artworkId) async {
    // 로그인 상태면 서버가 낙찰 여부(wonByViewer)까지 채워 내려주므로 토큰을 함께 보낸다.
    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/artworks/$artworkId'),
      headers: authOnlyHeaders(),
    );
    if (response.statusCode != 200) {
      throw StateError('작품 상세 조회 실패: ${response.statusCode}');
    }
    final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return ArtworkDetail.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<ArtworkDetail> closeAuction(int artworkId) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/artworks/$artworkId/close'),
      headers: authJsonHeaders(),
    );
    final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw StateError(body['message'] as String? ?? '경매 마감 실패: ${response.statusCode}');
    }
    return ArtworkDetail.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<ArtworkDetail> placeBid(int artworkId, int amount) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/artworks/$artworkId/bids'),
      headers: authJsonHeaders(),
      body: jsonEncode({'amount': amount}),
    );
    final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw StateError(body['message'] as String? ?? '입찰 실패: ${response.statusCode}');
    }
    return ArtworkDetail.fromJson(body['data'] as Map<String, dynamic>);
  }
}
