/// 약속(매칭) 상세 정보 모델.
///
/// 날짜 달력에서 특정 날짜에 외국인과 매칭된 약속이 있을 때 표시한다.
/// 현재는 백엔드/매칭 연동 전이라 mock 데이터를 사용한다.
class Appointment {
  final String mateName; // 만날 사람
  final String place; // 장소
  final String contentTitle; // 콘텐츠
  final DateTime date; // 약속 날짜
  final String startTime; // 시작 시각 "14:00"
  final String endTime; // 종료 시각 "17:00"

  const Appointment({
    required this.mateName,
    required this.place,
    required this.contentTitle,
    required this.date,
    required this.startTime,
    required this.endTime,
  });
}

/// 약속이 잡힌 날짜 목록 (mock).
///
/// 홈 날짜 달력에서 "약속이 있는 날짜"만 색칠하고, 그날 매칭된 외국인 이름을
/// 셀에 표시하기 위해 사용한다. 오늘 기준 상대 날짜로 생성해 이번 달 달력에
/// 항상 몇 개가 보이도록 한다.
///
/// TODO(서버 연동): 실제로는 아래 mock 대신 서버에서 기간별 약속 목록을 조회한다.
///   예) GET /api/appointments?from=2026-07-01&to=2026-07-31
///   응답 예시 (`BaseResponse<List<AppointmentResponse>>`):
///   {
///     "code": "SUCCESS",
///     "message": null,
///     "data": [
///       {
///         "appointmentId": 1,
///         "date": "2026-07-08",        // 약속 날짜 (yyyy-MM-dd)
///         "mateName": "Matthew",       // 매칭된 외국인 표시 이름 (달력 셀에 노출)
///         "mateUserId": 42,            // 상대 사용자 ID (상세/채팅 이동용)
///         "place": "홍대입구역 2번 출구",
///         "contentTitle": "한옥마을 투어",
///         "startTime": "14:00",        // HH:mm
///         "endTime": "17:00",
///         "status": "CONFIRMED"        // PENDING | CONFIRMED | COMPLETED | CANCELLED
///       }
///     ],
///     "timestamp": "2026-07-05T09:00:00Z"
///   }
final List<Appointment> mockAppointments = _buildMockAppointments();

List<Appointment> _buildMockAppointments() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return [
    Appointment(
      mateName: 'Matthew',
      place: '홍대입구역 2번 출구',
      contentTitle: '한옥마을 투어',
      date: today.add(const Duration(days: 2)),
      startTime: '14:00',
      endTime: '17:00',
    ),
    Appointment(
      mateName: 'Emma',
      place: '경복궁역 4번 출구',
      contentTitle: '서울 야경 투어',
      date: today.add(const Duration(days: 6)),
      startTime: '18:00',
      endTime: '21:00',
    ),
    Appointment(
      mateName: 'Sophie',
      place: '성수동 카페거리',
      contentTitle: '카페 호핑',
      date: today.add(const Duration(days: 11)),
      startTime: '13:00',
      endTime: '16:00',
    ),
  ];
}

/// 해당 날짜(시각 무시)에 잡힌 약속을 반환. 없으면 null.
///
/// TODO(서버 연동): [mockAppointments]를 서버에서 조회한 실제 목록으로 교체.
Appointment? appointmentOn(DateTime date) {
  final target = DateTime(date.year, date.month, date.day);
  for (final a in mockAppointments) {
    if (DateTime(a.date.year, a.date.month, a.date.day) == target) return a;
  }
  return null;
}
