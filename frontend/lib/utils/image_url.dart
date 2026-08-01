import '../constants/api_config.dart';

/// 백엔드가 내려주는 이미지 경로를 화면에서 바로 쓸 수 있는 절대 URL 로 바꾼다.
///
/// 업로드 이미지(`/images/...`)와 시드 이미지(`/artworks/...`)는 서버 기준 상대 경로로
/// 내려오므로 apiBaseUrl 을 붙여야 한다. 이미 절대 URL(카카오 프로필 등)이면 그대로 둔다.
String resolveImageUrl(String url) {
  if (url.isEmpty) return url;
  if (url.startsWith('http://') || url.startsWith('https://')) return url;
  if (url.startsWith('/')) return '$apiBaseUrl$url';
  return '$apiBaseUrl/$url';
}
