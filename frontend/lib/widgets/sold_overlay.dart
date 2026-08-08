import 'package:flutter/material.dart';

import '../constants/art_tokens.dart';

/// 살 수 없는 작품 썸네일 위에 덮는 딤 + 상태 칩.
///
/// 피드·더보기 목록·관심 작품이 같은 표시를 쓰도록 한 곳에 모아둔다.
/// 썸네일과 같은 Stack 안에서 [Positioned.fill] 로 감싸 쓴다.
/// 예약([reserved])은 결제 전이라 풀릴 수 있으므로 '판매 완료' 와 구분해 보여준다.
class SoldOverlay extends StatelessWidget {
  const SoldOverlay({super.key, this.borderRadius, this.reserved = false});

  /// 썸네일 모서리와 맞추기 위한 반경(카드 상단만 둥근 경우 등).
  final BorderRadiusGeometry? borderRadius;

  /// 예약 중이면 '예약중' 으로, 아니면 '판매 완료' 로 표시한다.
  final bool reserved;

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
                horizontal: ArtSpacing.md, vertical: 6),
            decoration: BoxDecoration(
              color: ArtColors.bgSurface,
              borderRadius: BorderRadius.circular(ArtRadius.full),
            ),
            child: Text(
              reserved ? '예약중' : '판매 완료',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: ArtColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
