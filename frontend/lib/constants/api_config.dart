/// REST API 베이스 URL (배포된 백엔드 서버).
///
/// 원격 서버라 iOS/Android 동일한 주소를 사용한다.
/// 로컬 백엔드로 테스트하려면 iOS는 http://localhost:8080,
/// Android 에뮬레이터는 http://10.0.2.2:8080 으로 바꿔서 쓴다.
String get apiBaseUrl => const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8080',
    );

/// 한국관광공사 관광정보 서비스 GW (TourAPI 4.0) 호스트/경로.
/// 사용자 역할에 따라 국문(KorService2)/영문(EngService2)을 분기한다
/// (분기는 [TourApiService.lang]가 담당).
const String tourApiHost = 'apis.data.go.kr';
const String tourApiKorBasePath = '/B551011/KorService2'; // 한국인 대학생
const String tourApiEngBasePath = '/B551011/EngService2'; // 외국인

/// data.go.kr service key supplied at build time.
///
/// Pass it with `--dart-define=TOUR_API_SERVICE_KEY=...` during local runs.
const String tourApiServiceKey =
    String.fromEnvironment('TOUR_API_SERVICE_KEY');
