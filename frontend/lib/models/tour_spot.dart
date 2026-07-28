/// 한국관광공사 국문 관광정보(GW) 위치 기반 관광지 항목 모델.
///
/// `locationBasedList2` 응답의 `items.item[]` 한 건을 표현한다.
class TourSpot {
  final String contentId;
  final String title;
  final String addr1;
  final String? firstImage;
  final double? mapX; // 경도(lng)
  final double? mapY; // 위도(lat)
  final double? dist; // 기준 좌표로부터 거리(m)
  final String? contentTypeId;
  final String? eventStartDate; // 행사시작일 YYYYMMDD (searchFestival2)
  final String? eventEndDate; // 행사종료일 YYYYMMDD (searchFestival2)

  const TourSpot({
    required this.contentId,
    required this.title,
    required this.addr1,
    this.firstImage,
    this.mapX,
    this.mapY,
    this.dist,
    this.contentTypeId,
    this.eventStartDate,
    this.eventEndDate,
  });

  factory TourSpot.fromJson(Map<String, dynamic> json) {
    String str(Object? v) => (v ?? '').toString().trim();
    double? toDouble(Object? v) {
      final s = str(v);
      if (s.isEmpty) return null;
      return double.tryParse(s);
    }

    final image = str(json['firstimage']);
    final image2 = str(json['firstimage2']);
    final resolvedImage = image.isNotEmpty
        ? image
        : (image2.isNotEmpty ? image2 : null);

    return TourSpot(
      contentId: str(json['contentid']),
      title: str(json['title']),
      addr1: str(json['addr1']),
      firstImage: resolvedImage,
      mapX: toDouble(json['mapx']),
      mapY: toDouble(json['mapy']),
      dist: toDouble(json['dist']),
      contentTypeId: str(json['contenttypeid']).isEmpty
          ? null
          : str(json['contenttypeid']),
      eventStartDate: str(json['eventstartdate']).isEmpty
          ? null
          : str(json['eventstartdate']),
      eventEndDate: str(json['eventenddate']).isEmpty
          ? null
          : str(json['eventenddate']),
    );
  }
}
