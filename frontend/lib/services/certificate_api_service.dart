import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_config.dart';
import '../models/certificate.dart';
import 'api_headers.dart';

class CertificateApiService {
  const CertificateApiService();

  Future<List<Ownership>> fetchOwnerships() async {
    // 내 소유권 목록이라 서버가 JWT 신원으로 스코프한다 — 인증 헤더 필수.
    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/certificates'),
      headers: authOnlyHeaders(),
    );
    if (response.statusCode != 200) {
      throw StateError('디지털 소유권 조회 실패: ${response.statusCode}');
    }
    final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>? ?? const {};
    final ownerships = data['ownerships'];
    if (ownerships is! List) return const [];
    return ownerships
        .whereType<Map<String, dynamic>>()
        .map(Ownership.fromJson)
        .toList();
  }

  Future<Certificate> scan(String qrCode) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/certificates/scan'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'qrCode': qrCode}),
    );
    final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw StateError(body['message'] as String? ?? 'QR 인증 실패: ${response.statusCode}');
    }
    return Certificate.fromJson(body['data'] as Map<String, dynamic>);
  }
}
