import 'package:flutter_test/flutter_test.dart';
import 'package:artnara/utils/server_time.dart';

void main() {
  group('parseServerTime', () {
    test('오프셋이 붙은 시각은 기기 시간대로 변환된다', () {
      final parsed = parseServerTime('2026-08-09T01:54:22+09:00');
      expect(parsed, isNotNull);
      // 어느 시간대에서 돌려도 같은 순간을 가리켜야 한다.
      expect(parsed!.toUtc(), DateTime.utc(2026, 8, 8, 16, 54, 22));
      expect(parsed.isUtc, isFalse);
    });

    test('오프셋 없는 구버전 응답은 예전처럼 기기 시간대로 읽는다', () {
      final parsed = parseServerTime('2026-08-09T01:54:22');
      expect(parsed, DateTime(2026, 8, 9, 1, 54, 22));
    });

    test('빈 값·문자열이 아닌 값은 null', () {
      expect(parseServerTime(null), isNull);
      expect(parseServerTime(''), isNull);
      expect(parseServerTime(123), isNull);
      expect(parseServerTime('시각 아님'), isNull);
    });
  });
}
