import 'package:flutter/material.dart';

import '../constants/dust_tokens.dart';

/// ART NARA 워드마크.
///
/// 디자인 파일(Figma "DUST-ART")에서 받은 워드마크 이미지는 옛 브랜드명이 박혀 있어,
/// 같은 조판(넓은 자간 + 글자 사이 오렌지 점)을 텍스트로 다시 그린다.
class ArtNaraWordmark extends StatelessWidget {
  const ArtNaraWordmark({
    super.key,
    this.fontSize = 40,
    this.color = DustColors.brandPrimary,
  });

  final double fontSize;
  final Color color;

  /// 워드마크의 포인트 컬러 (디자인의 'A' 위 점)
  static const Color accent = Color(0xFFD67A46);

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: fontSize * 0.12,
      color: color,
      height: 1.1,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('ART', style: style),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: fontSize * 0.16),
          child: Container(
            width: fontSize * 0.16,
            height: fontSize * 0.16,
            decoration: const BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Text('NARA', style: style),
      ],
    );
  }
}
