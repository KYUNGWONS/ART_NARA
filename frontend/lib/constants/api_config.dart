/// REST API 베이스 URL (배포된 백엔드 서버).
///
/// 원격 서버라 iOS/Android 동일한 주소를 사용한다.
/// 로컬 백엔드로 테스트하려면 iOS는 http://localhost:8080,
/// Android 에뮬레이터는 http://10.0.2.2:8080 으로 바꿔서 쓴다.
String get apiBaseUrl => const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8080',
    );

/// 백엔드 STOMP 엔드포인트. REST 베이스 URL(http/https)을 ws/wss 로 바꿔 쓴다.
/// 채팅과 경매 현황이 같은 연결을 쓴다.
String get websocketUrl =>
    '${apiBaseUrl.replaceFirst(RegExp(r'^http'), 'ws')}/ws';
