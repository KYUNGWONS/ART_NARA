import 'package:flutter/services.dart';

/// 금액 입력란용 포매터 — 숫자만 받아 천단위 콤마를 붙인다.
///
/// 입력 중에도 `1,234,000` 처럼 보이게 하고, 커서는 항상 끝으로 보낸다
/// (금액은 뒤에서 이어 치는 게 자연스럽다).
/// 값을 읽을 때는 [digitsOf] 로 콤마를 걷어낸다.
class WonInputFormatter extends TextInputFormatter {
  const WonInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();

    final formatted = formatDigits(digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// "1234000" → "1,234,000"
  static String formatDigits(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// 콤마·기호를 걷어낸 순수 숫자. 없으면 null.
  static int? digitsOf(String text) =>
      int.tryParse(text.replaceAll(RegExp(r'[^0-9]'), ''));
}
