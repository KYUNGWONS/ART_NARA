import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_config.dart';
import '../models/certificate.dart';

class CertificateApiService {
  const CertificateApiService();

  Future<List<Ownership>> fetchOwnerships() async {
    final response = await http.get(Uri.parse('$apiBaseUrl/api/certificates'));
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
