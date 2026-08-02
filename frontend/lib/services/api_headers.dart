import 'auth_api_service.dart';

/// 인증이 필요한 요청에 붙일 공통 헤더.
///
/// 서버는 조회(GET)만 공개하고 상태를 바꾸는 요청은 모두 로그인(JWT)을 요구한다.
/// 서비스마다 헤더를 따로 만들다 빠뜨리는 일을 막기 위해 여기서만 만든다.
Map<String, String> authJsonHeaders() => {
      'Content-Type': 'application/json',
      ...authOnlyHeaders(),
    };

/// 본문 타입을 직접 정하는 요청(멀티파트 등)용 — 인증 헤더만.
Map<String, String> authOnlyHeaders() {
  final token = AuthApiService.accessToken;
  if (token == null || token.isEmpty) return const {};
  return {'Authorization': 'Bearer $token'};
}
