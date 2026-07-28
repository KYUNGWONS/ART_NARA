import 'dart:ui' show Size;

// TODO: provinceClusters, districtClusters → GET /api/map/regions 등 API 응답으로 교체

/// 지역 클러스터 마커 데이터 모델
/// 줌 레벨에 따라 광역(Province) / 기초(District) 단위로 전환
class RegionCluster {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final int mateCount;
  final RegionLevel level;

  const RegionCluster({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.mateCount,
    required this.level,
  });
}

enum RegionLevel { province, district }

// ─── 줌 레벨 기준 ───
const double zoomThreshold = 10.5;

// ─── 광역 단위 더미 데이터 (도/특별시/광역시) ───
final List<RegionCluster> provinceClusters = [
  const RegionCluster(
    id: 'seoul',
    name: '서울',
    lat: 37.5665,
    lng: 126.9780,
    mateCount: 50,
    level: RegionLevel.province,
  ),
  const RegionCluster(
    id: 'gyeonggi',
    name: '경기',
    lat: 37.2750,
    lng: 127.0095,
    mateCount: 10,
    level: RegionLevel.province,
  ),
  // 고양(일산)은 경기도 내 도시이지만, 광역 지도에서 별도 핀으로 노출하기 위해
  // 광역 클러스터로 추가. 지역 콘텐츠 조회는 시·도 단위(경기, areaCode 31)로 처리.
  const RegionCluster(
    id: 'goyang',
    name: '고양',
    lat: 37.6584,
    lng: 126.8320,
    mateCount: 0,
    level: RegionLevel.province,
  ),
  const RegionCluster(
    id: 'busan',
    name: '부산',
    lat: 35.1796,
    lng: 129.0756,
    mateCount: 0,
    level: RegionLevel.province,
  ),
  const RegionCluster(
    id: 'daegu',
    name: '대구',
    lat: 35.8714,
    lng: 128.6014,
    mateCount: 0,
    level: RegionLevel.province,
  ),
  const RegionCluster(
    id: 'incheon',
    name: '인천',
    lat: 37.4563,
    lng: 126.7052,
    mateCount: 0,
    level: RegionLevel.province,
  ),
  const RegionCluster(
    id: 'gwangju',
    name: '광주',
    lat: 35.1595,
    lng: 126.8526,
    mateCount: 0,
    level: RegionLevel.province,
  ),
  const RegionCluster(
    id: 'daejeon',
    name: '대전',
    lat: 36.3504,
    lng: 127.3845,
    mateCount: 0,
    level: RegionLevel.province,
  ),
  const RegionCluster(
    id: 'ulsan',
    name: '울산',
    lat: 35.5384,
    lng: 129.3114,
    mateCount: 0,
    level: RegionLevel.province,
  ),
  const RegionCluster(
    id: 'sejong',
    name: '세종',
    lat: 36.4800,
    lng: 127.0000,
    mateCount: 0,
    level: RegionLevel.province,
  ),
  const RegionCluster(
    id: 'gangwon',
    name: '강원',
    lat: 37.8228,
    lng: 128.1555,
    mateCount: 0,
    level: RegionLevel.province,
  ),
  const RegionCluster(
    id: 'chungbuk',
    name: '충북',
    lat: 36.6357,
    lng: 127.4912,
    mateCount: 0,
    level: RegionLevel.province,
  ),
  const RegionCluster(
    id: 'chungnam',
    name: '충남',
    lat: 36.6588,
    lng: 126.6728,
    mateCount: 0,
    level: RegionLevel.province,
  ),
  const RegionCluster(
    id: 'jeonbuk',
    name: '전북',
    lat: 35.8203,
    lng: 127.1088,
    mateCount: 0,
    level: RegionLevel.province,
  ),
  const RegionCluster(
    id: 'jeonnam',
    name: '전남',
    lat: 34.8161,
    lng: 126.4629,
    mateCount: 0,
    level: RegionLevel.province,
  ),
  const RegionCluster(
    id: 'gyeongbuk',
    name: '경북',
    lat: 36.4919,
    lng: 128.8889,
    mateCount: 0,
    level: RegionLevel.province,
  ),
  const RegionCluster(
    id: 'gyeongnam',
    name: '경남',
    lat: 35.4606,
    lng: 128.2132,
    mateCount: 0,
    level: RegionLevel.province,
  ),
  const RegionCluster(
    id: 'jeju',
    name: '제주',
    lat: 33.4996,
    lng: 126.5312,
    mateCount: 0,
    level: RegionLevel.province,
  ),
];

// ─── 기초 단위 더미 데이터 (서울 구 단위) ───
final List<RegionCluster> districtClusters = [
  const RegionCluster(
    id: 'seoul_jongno',
    name: '종로구',
    lat: 37.5735,
    lng: 126.9790,
    mateCount: 10,
    level: RegionLevel.district,
  ),
  const RegionCluster(
    id: 'seoul_jung',
    name: '중구',
    lat: 37.5641,
    lng: 126.9979,
    mateCount: 10,
    level: RegionLevel.district,
  ),
  const RegionCluster(
    id: 'seoul_yongsan',
    name: '용산구',
    lat: 37.5326,
    lng: 126.9907,
    mateCount: 10,
    level: RegionLevel.district,
  ),
  const RegionCluster(
    id: 'seoul_seongdong',
    name: '성동구',
    lat: 37.5634,
    lng: 127.0369,
    mateCount: 10,
    level: RegionLevel.district,
  ),
  const RegionCluster(
    id: 'seoul_gwangjin',
    name: '광진구',
    lat: 37.5385,
    lng: 127.0824,
    mateCount: 10,
    level: RegionLevel.district,
  ),
  const RegionCluster(
    id: 'seoul_dongdaemun',
    name: '동대문구',
    lat: 37.5744,
    lng: 127.0399,
    mateCount: 0,
    level: RegionLevel.district,
  ),
  const RegionCluster(
    id: 'seoul_jungnang',
    name: '중랑구',
    lat: 37.6066,
    lng: 127.0928,
    mateCount: 0,
    level: RegionLevel.district,
  ),
  const RegionCluster(
    id: 'seoul_seongbuk',
    name: '성북구',
    lat: 37.5894,
    lng: 127.0167,
    mateCount: 0,
    level: RegionLevel.district,
  ),
  const RegionCluster(
    id: 'seoul_gangbuk',
    name: '강북구',
    lat: 37.6397,
    lng: 127.0115,
    mateCount: 0,
    level: RegionLevel.district,
  ),
  const RegionCluster(
    id: 'seoul_dobong',
    name: '도봉구',
    lat: 37.6688,
    lng: 127.0471,
    mateCount: 0,
    level: RegionLevel.district,
  ),
  const RegionCluster(
    id: 'seoul_nowon',
    name: '노원구',
    lat: 37.6542,
    lng: 127.0568,
    mateCount: 0,
    level: RegionLevel.district,
  ),
  const RegionCluster(
    id: 'seoul_eunpyeong',
    name: '은평구',
    lat: 37.6027,
    lng: 126.9291,
    mateCount: 0,
    level: RegionLevel.district,
  ),
  const RegionCluster(
    id: 'seoul_seodaemun',
    name: '서대문구',
    lat: 37.5791,
    lng: 126.9368,
    mateCount: 0,
    level: RegionLevel.district,
  ),
  const RegionCluster(
    id: 'seoul_mapo',
    name: '마포구',
    lat: 37.5664,
    lng: 126.9014,
    mateCount: 0,
    level: RegionLevel.district,
  ),
  const RegionCluster(
    id: 'seoul_yangcheon',
    name: '양천구',
    lat: 37.5170,
    lng: 126.8664,
    mateCount: 0,
    level: RegionLevel.district,
  ),
  const RegionCluster(
    id: 'seoul_gangseo',
    name: '강서구',
    lat: 37.5510,
    lng: 126.8495,
    mateCount: 0,
    level: RegionLevel.district,
  ),
  const RegionCluster(
    id: 'seoul_guro',
    name: '구로구',
    lat: 37.4955,
    lng: 126.8878,
    mateCount: 0,
    level: RegionLevel.district,
  ),
  const RegionCluster(
    id: 'seoul_geumcheon',
    name: '금천구',
    lat: 37.4519,
    lng: 126.8956,
    mateCount: 0,
    level: RegionLevel.district,
  ),
  const RegionCluster(
    id: 'seoul_yeongdeungpo',
    name: '영등포구',
    lat: 37.5264,
    lng: 126.8963,
    mateCount: 0,
    level: RegionLevel.district,
  ),
  const RegionCluster(
    id: 'seoul_dongjak',
    name: '동작구',
    lat: 37.5124,
    lng: 126.9393,
    mateCount: 0,
    level: RegionLevel.district,
  ),
  const RegionCluster(
    id: 'seoul_gwanak',
    name: '관악구',
    lat: 37.4784,
    lng: 126.9516,
    mateCount: 0,
    level: RegionLevel.district,
  ),
  const RegionCluster(
    id: 'seoul_seocho',
    name: '서초구',
    lat: 37.4837,
    lng: 127.0324,
    mateCount: 0,
    level: RegionLevel.district,
  ),
  const RegionCluster(
    id: 'seoul_gangnam',
    name: '강남구',
    lat: 37.5172,
    lng: 127.0473,
    mateCount: 0,
    level: RegionLevel.district,
  ),
  const RegionCluster(
    id: 'seoul_songpa',
    name: '송파구',
    lat: 37.5146,
    lng: 127.1050,
    mateCount: 0,
    level: RegionLevel.district,
  ),
  const RegionCluster(
    id: 'seoul_gangdong',
    name: '강동구',
    lat: 37.5301,
    lng: 127.1238,
    mateCount: 0,
    level: RegionLevel.district,
  ),
];

/// 광역(시·도) 클러스터 id → 한국관광공사 TourAPI areaCode
/// areaBasedList2 의 areaCode 파라미터에 사용한다.
/// (RegionCluster 에 필드로 넣지 않는 이유: _clustersWithMateCounts 가
///  객체를 재생성하며 누락될 위험이 있어 id 기준 별도 맵으로 관리)
const Map<String, String> sidoAreaCodes = {
  'seoul': '1',
  'incheon': '2',
  'daejeon': '3',
  'daegu': '4',
  'gwangju': '5',
  'busan': '6',
  'ulsan': '7',
  'sejong': '8',
  'gyeonggi': '31',
  'goyang': '31', // 고양시는 경기도(31) 콘텐츠로 조회
  'gangwon': '32',
  'chungbuk': '33',
  'chungnam': '34',
  'gyeongbuk': '35',
  'gyeongnam': '36',
  'jeonbuk': '37',
  'jeonnam': '38',
  'jeju': '39',
};

/// 클러스터 id → TourAPI 시·군·구 코드(sigunguCode)
/// 시·도(sidoAreaCodes)만으로 너무 넓어 도시 단위로 좁혀야 하는 핀에만 지정한다.
/// (예: 고양은 경기도(areaCode 31) 안의 고양시(sigunguCode 2))
const Map<String, String> sigunguCodes = {
  'goyang': '2', // 경기도(31) > 고양시
};

/// 핀 마커 크기 계산 (메이트 수 기반 스케일링)
/// 핀은 세로가 가로의 약 1.3배 비율
/// minWidth ~ maxWidth 범위에서 mateCount에 비례하여 크기 결정
Size calculatePinSize({
  required int mateCount,
  required int maxCountInGroup,
  double minWidth = 24,
  double maxWidth = 52,
}) {
  if (maxCountInGroup <= 0) return Size(minWidth, minWidth * 1.3);

  final ratio = (mateCount / maxCountInGroup).clamp(0.0, 1.0);
  // 최소 비율 0.4를 보장하여 너무 작은 핀 방지
  final adjusted = 0.4 + (ratio * 0.6);
  final width = minWidth + (adjusted * (maxWidth - minWidth));
  final height = width * 1.3;
  return Size(width, height);
}
