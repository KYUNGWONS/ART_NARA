/// 콘텐츠 생성 플로우(5단계) 전반에서 사용자가 선택한 값을 누적하는 임시 모델.
///
/// `ContentCreateFlowScreen`이 단일 인스턴스를 보유하고, 각 step이 콜백으로
/// 값을 채워 넣는다. 마지막에 `ContentApiService.submitContent`로 전달된다.
class ContentDraft {
  /// 가능한 요일 (다중 선택) — 예: ['화', '금']
  final List<String> days = [];

  /// 테마 (단일 선택) — '장소' / '공연' / '활동'
  String? theme;

  /// 시간대 (단일 선택) — '오전 ~ 점심' 등
  String? timeSlot;

  /// 장소 (단일 선택) — '한강'
  String? place;

  /// 장소 썸네일 이미지 URL
  String? placeImage;

  /// 활동 (단일 선택) — '따릉이'
  String? activity;

  /// 활동 썸네일 이미지 URL
  String? activityImage;

  /// 콘텐츠 제목 (미입력 시 place/activity로 자동 구성)
  String? title;

  /// 활동비 (원). 현재 플로우에서 입력받지 않으면 0.
  int price = 0;

  /// 사용자가 입력한 소개글
  String description = '';

  // ─── 백엔드 enum 매핑 (프론트 한글 라벨 → 백엔드 enum 값) ───

  static const Map<String, String> _dayToEnum = {
    '월': 'MONDAY',
    '화': 'TUESDAY',
    '수': 'WEDNESDAY',
    '목': 'THURSDAY',
    '금': 'FRIDAY',
    '토': 'SATURDAY',
    '일': 'SUNDAY',
  };

  static const Map<String, String> _themeToEnum = {
    '장소': 'PLACE',
    '공연': 'PERFORMANCE',
    '활동': 'ACTIVITY',
  };

  static const Map<String, String> _timeSlotToEnum = {
    '오전 ~ 점심': 'MORNING_TO_LUNCH',
    '점심 ~ 저녁': 'LUNCH_TO_DINNER',
    '저녁 ~ 밤': 'DINNER_TO_NIGHT',
  };

  /// 제목 미입력 시 장소/활동으로 자동 구성.
  String get _resolvedTitle {
    if (title != null && title!.trim().isNotEmpty) return title!.trim();
    final parts = [
      place,
      activity,
    ].where((e) => e != null && e.isNotEmpty).cast<String>();
    final composed = parts.join(' ');
    return composed.isNotEmpty ? composed : '내 콘텐츠';
  }

  /// 서버 전송용 JSON 바디 (백엔드 ContentDto.CreateRequest 스키마).
  Map<String, dynamic> toJson() => <String, dynamic>{
    'title': _resolvedTitle,
    'description': description,
    'theme': theme != null ? _themeToEnum[theme] : null,
    'place': place,
    'activity': activity,
    'timeSlot': timeSlot != null ? _timeSlotToEnum[timeSlot] : null,
    'availableDays': days
        .map((d) => _dayToEnum[d])
        .where((e) => e != null)
        .toList(),
    'coverImageUrl': placeImage ?? activityImage,
    'price': price,
  };
}
