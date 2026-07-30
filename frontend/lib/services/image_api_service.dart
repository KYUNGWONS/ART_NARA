import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../constants/api_config.dart';

class ImageApiService {
  const ImageApiService();

  /// 이미지 파일을 업로드하고 서버 이미지 URL(절대 경로)을 반환한다.
  Future<String> upload(String filePath) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$apiBaseUrl/api/images'),
    );
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: _contentTypeOf(filePath),
      ),
    );
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw StateError(
          body['message'] as String? ?? '이미지 업로드 실패: ${response.statusCode}');
    }
    final data = body['data'] as Map<String, dynamic>? ?? const {};
    final url = data['url'] as String? ?? '';
    return url.startsWith('http') ? url : '$apiBaseUrl$url';
  }

  MediaType _contentTypeOf(String filePath) {
    final lower = filePath.toLowerCase();
    if (lower.endsWith('.png')) return MediaType('image', 'png');
    if (lower.endsWith('.webp')) return MediaType('image', 'webp');
    return MediaType('image', 'jpeg');
  }
}
