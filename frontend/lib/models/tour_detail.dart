/// 한국관광공사 상세정보 조회 결과 모델.
///
/// `detailCommon2`(공통정보) + `detailIntro2`(소개정보) + `detailImage2`(이미지)
/// 응답을 하나로 합쳐 상세 화면에서 사용한다.
class TourDetail {
  final String contentId;
  final String? contentTypeId;
  final String title;
  final String? addr1;

  /// 축제 기간 "25.10.24 — 25.10.26" (contentTypeId=15 축제일 때만)
  final String? period;

  /// 타입별 핵심 정보(라벨:값) 목록
  final List<TourDetailInfo> infoItems;

  /// 콘텐츠 설명(detailCommon2.overview, HTML 태그 정리됨)
  final String? overview;

  /// 사진 슬라이드용 이미지 URL 목록(firstimage + detailImage2, 중복 제거)
  final List<String> imageUrls;

  const TourDetail({
    required this.contentId,
    this.contentTypeId,
    required this.title,
    this.addr1,
    this.period,
    this.infoItems = const [],
    this.overview,
    this.imageUrls = const [],
  });
}

/// 상세 화면에 보여줄 정보 한 줄 (예: '영업시간' → '10:00~20:00')
class TourDetailInfo {
  final String label;
  final String value;

  const TourDetailInfo({required this.label, required this.value});
}

/// contentTypeId → 타입 라벨 (배지 표시용).
/// 국문(KorService2)/영문(EngService2)은 코드 범위가 서로 달라(12~39 / 75~85)
/// 단일 맵으로 서비스에 맞는 언어 라벨이 자연스럽게 선택된다.
const Map<String, String> contentTypeLabels = {
  // 국문(KorService2)
  '12': '관광지',
  '14': '문화시설',
  '15': '축제',
  '25': '여행코스',
  '28': '레포츠',
  '32': '숙박',
  '38': '쇼핑',
  '39': '음식점',
  // 영문(EngService2)
  '76': 'Tourist Spot',
  '78': 'Cultural Facility',
  '85': 'Festival',
  '81': 'Travel Course',
  '75': 'Leisure Sports',
  '80': 'Accommodation',
  '79': 'Shopping',
  '82': 'Restaurant',
  '77': 'Transportation',
};

String contentTypeLabel(String? id) => contentTypeLabels[id] ?? '관광';

/// 관광 콘텐츠 종류 키 (국문/영문 코드 공통 정규화).
enum TourContentKind {
  touristSpot,
  culture,
  festival,
  course,
  leports,
  lodging,
  shopping,
  restaurant,
  transport,
}

/// contentTypeId(국문 12~39 또는 영문 75~85) → 공통 종류.
/// 상세 화면의 타입별 정보/축제 판정에서 서비스 언어와 무관하게 쓰인다.
TourContentKind? contentTypeKind(String? id) {
  switch (id) {
    case '12':
    case '76':
      return TourContentKind.touristSpot;
    case '14':
    case '78':
      return TourContentKind.culture;
    case '15':
    case '85':
      return TourContentKind.festival;
    case '25':
    case '81':
      return TourContentKind.course;
    case '28':
    case '75':
      return TourContentKind.leports;
    case '32':
    case '80':
      return TourContentKind.lodging;
    case '38':
    case '79':
      return TourContentKind.shopping;
    case '39':
    case '82':
      return TourContentKind.restaurant;
    case '77':
      return TourContentKind.transport;
    default:
      return null;
  }
}
