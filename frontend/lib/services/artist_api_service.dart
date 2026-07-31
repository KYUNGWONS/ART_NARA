import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_config.dart';
import '../models/artist_profile.dart';

class ArtistApiService {
  const ArtistApiService();

  Future<ArtistProfile> fetchPortfolio(String artistName) async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/artists/${Uri.encodeComponent(artistName)}'),
    );
    if (response.statusCode != 200) {
      throw StateError('작가 포트폴리오 조회 실패: ${response.statusCode}');
    }
    final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return ArtistProfile.fromJson(body['data'] as Map<String, dynamic>);
  }
}
