/// 사용자 위치 정보 모델
/// 추후 백엔드 API 연동 시 JSON 파싱으로 교체
class UserLocation {
  final String userId;
  final String nickname;
  final int? age;
  final String address;
  final double lat;
  final double lng;
  final String? profileImageUrl;
  final String role; // 'KOREAN_STUDENT' | 'FOREIGNER'
  final String? introduction;

  /// 관심사 id 목록: travel, food, activity, culture, cafe, unique
  final List<String> interests;

  /// 계획 vs 즉흥 (-100~+100, 0=중립, -100=즉흥형, +100=계획형)
  final int planningScore;

  /// 활발도 (-100~+100, 0=중립, -100=활발한편, +100=조용한편)
  final int activityScore;

  const UserLocation({
    required this.userId,
    required this.nickname,
    this.age,
    required this.address,
    required this.lat,
    required this.lng,
    this.profileImageUrl,
    required this.role,
    this.introduction,
    this.interests = const [],
    this.planningScore = 0,
    this.activityScore = 0,
  });
}

/// 임시 더미 데이터 (백엔드 미구현 상태)
/// 실제로는 GET /api/users/locations 같은 API로 대체 예정
/// 한국인 대학생만 주소를 입력하므로 마커도 한국인 대학생만 표시
final List<UserLocation> dummyUserLocations = [
  const UserLocation(
    userId: 'user_001',
    nickname: '재혁이',
    age: 28,
    address: '서울특별시 종로구',
    lat: 37.5735,
    lng: 126.9790,
    profileImageUrl:
        'https://k.kakaocdn.net/dn/cpObSK/dJMcabirNp2/6k8AYPwXmaMXKlGBRmWja0/img_640x640.jpg',
    role: 'KOREAN_STUDENT',
    introduction: '여행과 맛집 탐방을 좋아하는 컴퓨터 전공 대학생이에요!',
    interests: ['travel', 'food', 'culture'],
    planningScore: 40,
    activityScore: -40,
  ),
  const UserLocation(
    userId: 'user_002',
    nickname: '하늘이',
    age: 24,
    address: '서울특별시 종로구',
    lat: 37.5735,
    lng: 126.9790,
    profileImageUrl: null,
    role: 'KOREAN_STUDENT',
    introduction: "골목길 카페 투어와 전시회를 좋아하는 프로 힐링러입니다.",
    interests: ['travel', 'food', 'culture'],
    planningScore: 40,
    activityScore: -40,
  ),
  const UserLocation(
    userId: 'user_003',
    nickname: '준혁',
    age: 26,
    address: '서울특별시 강남구 테헤란로 212',
    lat: 37.5012,
    lng: 127.0396,
    profileImageUrl: null,
    role: 'KOREAN_STUDENT',
    introduction: "여행은 역시 텐션이죠! 축제랑 야경 사냥하러 갈 사람?",
    interests: ['cafe', 'food', 'activity'],
    planningScore: 0,
    activityScore: -10,
  ),
  const UserLocation(
    userId: 'user_004',
    nickname: 'Andy',
    age: 23,
    address: '서울특별시 성동구 왕십리로 222',
    lat: 37.5614,
    lng: 127.0380,
    profileImageUrl: null,
    role: 'KOREAN_STUDENT',
    introduction: '성수동 골목 exploration 전문가. 맛집 알려드릴게요~',
    interests: ['cafe', 'food', 'unique'],
    planningScore: -40,
    activityScore: -50,
  ),
  const UserLocation(
    userId: 'user_006',
    nickname: '민재',
    age: 27,
    address: '서울특별시 서대문구 이화여대길 52',
    lat: 37.5628,
    lng: 126.9468,
    profileImageUrl: null,
    role: 'KOREAN_STUDENT',
    introduction: '걷기 좋은 서울 골목길 안내해 드릴게요!',
    interests: ['travel', 'culture', 'unique'],
    planningScore: 60,
    activityScore: -20,
  ),
  // ─── 부산 ───
  const UserLocation(
    userId: 'user_007',
    nickname: '해운',
    age: 25,
    address: '부산광역시 해운대구 해운대해변로',
    lat: 35.1631,
    lng: 129.1635,
    profileImageUrl: null,
    role: 'KOREAN_STUDENT',
    introduction: '바다 보면서 회 한 접시 어때요? 부산 토박이입니다!',
    interests: ['travel', 'food', 'activity'],
    planningScore: -20,
    activityScore: -60,
  ),
  const UserLocation(
    userId: 'user_008',
    nickname: '서면러',
    age: 24,
    address: '부산광역시 부산진구 서면',
    lat: 35.1579,
    lng: 129.0594,
    profileImageUrl: null,
    role: 'KOREAN_STUDENT',
    introduction: '서면 맛집, 광안리 야경 다 안내해 드려요~',
    interests: ['food', 'cafe', 'culture'],
    planningScore: 10,
    activityScore: -30,
  ),
  // ─── 고양(일산) ───
  const UserLocation(
    userId: 'user_009',
    nickname: '일산댁',
    age: 26,
    address: '경기도 고양시 일산동구 중앙로',
    lat: 37.6584,
    lng: 126.7745,
    profileImageUrl: null,
    role: 'KOREAN_STUDENT',
    introduction: '호수공원 산책하고 라페스타에서 카페 투어해요!',
    interests: ['travel', 'cafe', 'culture'],
    planningScore: 30,
    activityScore: -10,
  ),
  const UserLocation(
    userId: 'user_010',
    nickname: '덕양',
    age: 28,
    address: '경기도 고양시 덕양구',
    lat: 37.6376,
    lng: 126.8326,
    profileImageUrl: null,
    role: 'KOREAN_STUDENT',
    introduction: '행주산성부터 스타필드까지, 고양 구석구석 알려드려요.',
    interests: ['travel', 'food', 'activity'],
    planningScore: 50,
    activityScore: -40,
  ),
];
