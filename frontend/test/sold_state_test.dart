import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:artnara/models/artwork_detail.dart';
import 'package:artnara/models/home_feed.dart';
import 'package:artnara/widgets/sold_overlay.dart';

/// 판매 완료 상태가 모델에서 화면까지 이어지는지 확인한다.
/// (에뮬레이터 로그인 없이도 회귀를 잡기 위한 테스트)
void main() {
  group('판매 완료 상태 파싱', () {
    test('피드 작품은 sold 를 읽는다', () {
      final sold = Artwork.fromJson(const {
        'id': 1,
        'title': '봄의 정원',
        'artistName': '김예진',
        'price': 320000,
        'imageUrl': '',
        'liked': false,
        'auction': false,
        'sold': true,
      });
      expect(sold.sold, isTrue);
    });

    test('sold 가 없으면 판매 중으로 본다', () {
      final selling = Artwork.fromJson(const {
        'id': 2,
        'title': '무채색의 위로',
        'artistName': '박소현',
        'price': 180000,
        'imageUrl': '',
        'liked': false,
        'auction': false,
      });
      expect(selling.sold, isFalse);
    });

    test('작품 상세도 sold 를 읽는다', () {
      final detail = ArtworkDetail.fromJson(const {
        'id': 1,
        'title': '봄의 정원',
        'artistName': '김예진',
        'artistIntroduction': '',
        'description': '',
        'imageUrl': '',
        'medium': '캔버스에 유화',
        'size': '53.0 x 45.5cm (10호)',
        'year': 2026,
        'price': 320000,
        'auction': false,
        'minBidIncrement': 10000,
        'certified': true,
        'auctionClosed': false,
        'sold': true,
        'bidHistory': <Map<String, dynamic>>[],
      });
      expect(detail.sold, isTrue);
    });
  });

  testWidgets('판매 완료 오버레이는 아래 탭을 가로막지 않는다', (tester) async {
    // 카드 전체 탭(작품 상세 열기)이 딤 때문에 죽으면 안 된다.
    var tapped = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 200,
            height: 160,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => tapped++,
                    child: const ColoredBox(color: Colors.grey),
                  ),
                ),
                const Positioned.fill(child: SoldOverlay()),
              ],
            ),
          ),
        ),
      ),
    ));

    // 칩 한가운데를 눌러도 아래 카드가 받아야 한다.
    await tester.tapAt(tester.getCenter(find.byType(SoldOverlay)));
    expect(tapped, 1);
  });

  testWidgets('판매 완료 오버레이는 배지를 그린다', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 200,
          height: 160,
          child: Stack(children: [Positioned.fill(child: SoldOverlay())]),
        ),
      ),
    ));

    expect(find.text('판매 완료'), findsOneWidget);
  });
}
