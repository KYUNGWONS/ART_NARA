/// 서버가 내려준 시각 문자열을 기기 시간대로 읽는다.
///
/// 서버는 오프셋을 붙여 내린다("2026-08-09T01:54:22+09:00"). 그대로 `DateTime.parse`
/// 하면 UTC 기준 값이 나오므로 `toLocal()` 로 기기 시간대에 맞춰야 화면 시각이 맞는다.
/// 오프셋이 없는 구버전 응답("2026-08-09T01:54:22")은 기기 시간대로 해석되고
/// `toLocal()` 이 아무 일도 하지 않으므로 예전과 똑같이 동작한다.
DateTime? parseServerTime(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value)?.toLocal();
}
