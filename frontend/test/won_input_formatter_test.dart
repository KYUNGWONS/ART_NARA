import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:artnara/widgets/won_input_formatter.dart';

TextEditingValue _v(String text) => TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );

void main() {
  const formatter = WonInputFormatter();

  group('금액 입력 포매팅', () {
    test('치는 동안 천단위 콤마가 붙는다', () {
      expect(formatter.formatEditUpdate(_v('26000'), _v('260000')).text,
          '260,000');
      expect(formatter.formatEditUpdate(_v('790000'), _v('7900000')).text,
          '7,900,000');
    });

    test('세 자리 이하는 콤마가 없다', () {
      expect(formatter.formatEditUpdate(const TextEditingValue(), _v('900')).text,
          '900');
    });

    test('숫자가 아닌 입력은 걸러낸다', () {
      expect(formatter.formatEditUpdate(const TextEditingValue(), _v('12만원')).text,
          '12');
    });

    test('전부 지우면 빈 값이 된다', () {
      expect(formatter.formatEditUpdate(_v('1,000'), _v('')).text, '');
    });

    test('커서는 항상 끝에 온다', () {
      final result = formatter.formatEditUpdate(_v('1000'), _v('10000'));
      expect(result.selection.baseOffset, result.text.length);
    });
  });

  group('금액 파싱', () {
    test('콤마를 걷어내고 숫자로 읽는다', () {
      expect(WonInputFormatter.digitsOf('7,900,000'), 7900000);
      expect(WonInputFormatter.digitsOf('₩ 260,000'), 260000);
    });

    test('숫자가 없으면 null', () {
      expect(WonInputFormatter.digitsOf(''), isNull);
      expect(WonInputFormatter.digitsOf('원'), isNull);
    });
  });
}
