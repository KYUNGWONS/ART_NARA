import 'package:flutter/material.dart';

import '../constants/dust_tokens.dart';

/// 판매 완료된 작품 썸네일 위에 덮는 딤 + '판매 완료' 칩.
///
/// 피드·더보기 목록·관심 작품이 같은 표시를 쓰도록 한 곳에 모아둔다.
/// 썸네일과 같은 Stack 안에서 [Positioned.fill] 로 감싸 쓴다.
class SoldOverlay extends StatelessWidget {
  const SoldOverlay({super.key, this.borderRadius});

  /// 썸네일 모서리와 맞추기 위한 반경(카드 상단만 둥근 경우 등).
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    // 순수 장식이다. 포인터를 먹으면 카드 탭(작품 상세)과 위에 얹은 하트가 죽는다.
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: borderRadius,
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: DustSpacing.md, vertical: 6),
            decoration: BoxDecoration(
              color: DustColors.bgSurface,
              borderRadius: BorderRadius.circular(DustRadius.full),
            ),
            child: const Text(
              '판매 완료',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: DustColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
