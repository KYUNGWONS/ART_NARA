// 콘텐츠 생성 플로우에서 사용하는 정적 옵션 데이터.
//
// 백엔드 콘텐츠 메타 API가 준비되기 전까지 사용하는 인메모리 참조 데이터다.
// 옵션 라벨은 한국어 우선으로 두며(추후 `AppStrings`로 로컬라이즈 가능),
// 이미지는 네트워크 플레이스홀더(picsum)를 사용한다 — 항상 로드되며,
// 카드의 errorBuilder가 오프라인 폴백을 담당한다.

/// Step 1 — 가능한 요일 (다중 선택)
const List<String> kDayOptions = ['월', '화', '수', '목', '금', '토', '일'];

/// Step 1 — 테마 (단일 선택)
const List<String> kThemeOptions = ['장소', '공연', '활동'];

/// Step 1 — 시간대 (단일 선택)
const List<String> kTimeSlotOptions = ['오전 ~ 점심', '점심 ~ 저녁', '저녁 ~ 밤'];

/// 이미지 + 라벨을 가진 선택 옵션(장소/활동 공용 구조).
class ContentOption {
  const ContentOption({
    required this.id,
    required this.label,
    required this.imageUrl,
  });

  final String id;
  final String label;
  final String imageUrl;
}

/// Step 2 — 장소 목록
const List<ContentOption> kPlaceOptions = [
  ContentOption(
    id: 'hangang',
    label: '한강',
    imageUrl: 'https://picsum.photos/seed/hangang/600/400',
  ),
  ContentOption(
    id: 'haebangchon',
    label: '해방촌',
    imageUrl: 'https://picsum.photos/seed/haebangchon/600/400',
  ),
  ContentOption(
    id: 'jongno',
    label: '종로',
    imageUrl: 'https://picsum.photos/seed/jongno/600/400',
  ),
  ContentOption(
    id: 'market',
    label: '전통시장',
    imageUrl: 'https://picsum.photos/seed/market/600/400',
  ),
];

/// Step 3 — 장소(id)별 활동 목록.
///
/// 활동은 선택한 장소에 따라 달라진다. 매핑에 없는 장소는
/// [kDefaultActivityOptions]로 폴백한다.
const Map<String, List<ContentOption>> kActivityOptionsByPlace = {
  'hangang': [
    ContentOption(
      id: 'chimaek',
      label: '치맥',
      imageUrl: 'https://picsum.photos/seed/chimaek/600/400',
    ),
    ContentOption(
      id: 'ddareungi',
      label: '따릉이',
      imageUrl: 'https://picsum.photos/seed/ddareungi/600/400',
    ),
    ContentOption(
      id: 'walk',
      label: '산책',
      imageUrl: 'https://picsum.photos/seed/walk/600/400',
    ),
    ContentOption(
      id: 'busking',
      label: '버스킹',
      imageUrl: 'https://picsum.photos/seed/busking/600/400',
    ),
  ],
  'haebangchon': [
    ContentOption(
      id: 'cafe',
      label: '카페',
      imageUrl: 'https://picsum.photos/seed/hbc_cafe/600/400',
    ),
    ContentOption(
      id: 'nightview',
      label: '야경',
      imageUrl: 'https://picsum.photos/seed/hbc_night/600/400',
    ),
    ContentOption(
      id: 'alley',
      label: '골목 산책',
      imageUrl: 'https://picsum.photos/seed/hbc_alley/600/400',
    ),
    ContentOption(
      id: 'photo',
      label: '사진',
      imageUrl: 'https://picsum.photos/seed/hbc_photo/600/400',
    ),
  ],
  'jongno': [
    ContentOption(
      id: 'hanok',
      label: '한옥',
      imageUrl: 'https://picsum.photos/seed/jongno_hanok/600/400',
    ),
    ContentOption(
      id: 'foodie',
      label: '맛집',
      imageUrl: 'https://picsum.photos/seed/jongno_food/600/400',
    ),
    ContentOption(
      id: 'exhibition',
      label: '전시',
      imageUrl: 'https://picsum.photos/seed/jongno_art/600/400',
    ),
    ContentOption(
      id: 'nightmarket',
      label: '야시장',
      imageUrl: 'https://picsum.photos/seed/jongno_night/600/400',
    ),
  ],
  'market': [
    ContentOption(
      id: 'streetfood',
      label: '먹거리',
      imageUrl: 'https://picsum.photos/seed/market_food/600/400',
    ),
    ContentOption(
      id: 'tteokbokki',
      label: '떡볶이',
      imageUrl: 'https://picsum.photos/seed/market_tteok/600/400',
    ),
    ContentOption(
      id: 'bargain',
      label: '흥정',
      imageUrl: 'https://picsum.photos/seed/market_bargain/600/400',
    ),
    ContentOption(
      id: 'browse',
      label: '구경',
      imageUrl: 'https://picsum.photos/seed/market_browse/600/400',
    ),
  ],
};

/// 매핑에 없는 장소를 위한 기본 활동 목록.
const List<ContentOption> kDefaultActivityOptions = [
  ContentOption(
    id: 'walk',
    label: '산책',
    imageUrl: 'https://picsum.photos/seed/walk/600/400',
  ),
  ContentOption(
    id: 'foodie',
    label: '맛집',
    imageUrl: 'https://picsum.photos/seed/foodie/600/400',
  ),
  ContentOption(
    id: 'cafe',
    label: '카페',
    imageUrl: 'https://picsum.photos/seed/cafe/600/400',
  ),
  ContentOption(
    id: 'photo',
    label: '사진',
    imageUrl: 'https://picsum.photos/seed/photo/600/400',
  ),
];

/// 장소 id에 해당하는 활동 목록을 반환한다(없으면 기본 목록).
List<ContentOption> activitiesForPlace(String? placeId) {
  if (placeId == null) return kDefaultActivityOptions;
  return kActivityOptionsByPlace[placeId] ?? kDefaultActivityOptions;
}
