import 'package:flutter/material.dart';

/// DUST-ART 디자인 토큰.
///
/// Figma "DUST-ART Foundations"(파일 LghoZTZPejVsF7jndmqJEm, node 25:210)에서
/// 그대로 옮긴 값이다. 새 화면은 하드코딩 대신 이 토큰을 사용할 것.
/// (Knot 잔재 화면들은 아직 [AppColors]를 쓰므로 점진적으로 교체한다.)
class DustColors {
  DustColors._();

  // ─── Primitives ───
  static const Color ivory = Color(0xFFF8F3E8);
  static const Color paper = Color(0xFFFEFCF7);
  static const Color subtle = Color(0xFFF0EBE3);
  static const Color teal = Color(0xFF07524E);
  static const Color tealDark = Color(0xFF084742);
  static const Color ink = Color(0xFF141413);
  static const Color muted = Color(0xFF6B665E);
  static const Color line = Color(0xFFE0DBD1);
  static const Color info = Color(0xFFE9F0F1);
  static const Color white = Color(0xFFFFFFFF);

  // ─── Semantic ───
  /// 화면 기본 배경 (warm ivory)
  static const Color bgCanvas = ivory;

  /// 카드·시트 표면
  static const Color bgSurface = paper;

  /// 톤 다운된 블록 배경
  static const Color bgSubtle = subtle;

  /// 정보성 배경
  static const Color bgInfo = info;

  /// 브랜드 기본 (deep teal) — CTA, 강조
  static const Color brandPrimary = teal;

  /// 브랜드 진한 톤 — pressed 상태 등
  static const Color brandDeep = tealDark;

  /// 기본 테두리
  static const Color borderSoft = line;

  /// 본문 텍스트
  static const Color textPrimary = ink;

  /// 보조 텍스트
  static const Color textSecondary = muted;

  /// 브랜드 배경 위 텍스트
  static const Color textOnBrand = white;
}

/// 타이포그래피 스케일. 폰트는 Noto Sans KR.
class DustText {
  DustText._();

  static const TextStyle heading = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: DustColors.textPrimary,
  );

  static const TextStyle section = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: DustColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: DustColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: DustColors.textSecondary,
  );
}

/// 간격 스케일 (8 · 12 · 16 · 24)
class DustSpacing {
  DustSpacing._();

  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
}

/// 모서리 반경 (8 · 14 · 22 · Full)
class DustRadius {
  DustRadius._();

  static const double sm = 8;
  static const double md = 14;
  static const double lg = 22;

  /// Full — pill 형태 버튼 등
  static const double full = 999;
}
