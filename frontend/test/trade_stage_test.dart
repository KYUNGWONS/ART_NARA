import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:artnara/models/order.dart';
import 'package:artnara/widgets/sold_overlay.dart';

/// 직거래는 예약 → 양쪽 수령 확인 → 결제 순서로 진행된다.
/// 화면이 어떤 버튼을 보여줄지가 이 플래그들에 달려 있어 계산 규칙을 굳혀둔다.
Order order({
  bool sellerConfirmed = false,
  bool buyerConfirmed = false,
  bool paid = false,
  bool cancelled = false,
  bool viewerIsSeller = false,
}) {
  return Order(
    orderId: 1,
    artworkId: 1,
    artworkTitle: '작품',
    artistName: '작가',
    amount: 100000,
    paymentMethod: '미정',
    status: '예약 중',
    certificateNo: '',
    orderedDate: '2026-08-08',
    refunded: false,
    sellerConfirmed: sellerConfirmed,
    buyerConfirmed: buyerConfirmed,
    paid: paid,
    cancelled: cancelled,
    viewerIsSeller: viewerIsSeller,
  );
}

void main() {
  group('직거래 단계', () {
    test('예약 직후에는 양쪽 다 확인이 필요하다', () {
      expect(order().needsMyConfirmation, isTrue);
      expect(order(viewerIsSeller: true).needsMyConfirmation, isTrue);
      expect(order().readyToPay, isFalse);
    });

    test('내가 확인했으면 내 버튼은 사라진다', () {
      expect(order(buyerConfirmed: true).needsMyConfirmation, isFalse);
      // 판매자는 아직 안 눌렀으므로 판매자 화면에서는 버튼이 남아 있다
      expect(order(buyerConfirmed: true, viewerIsSeller: true).needsMyConfirmation,
          isTrue);
    });

    test('양쪽이 확인해야 결제가 열린다', () {
      expect(order(buyerConfirmed: true).readyToPay, isFalse);
      expect(order(sellerConfirmed: true).readyToPay, isFalse);
      expect(order(sellerConfirmed: true, buyerConfirmed: true).readyToPay, isTrue);
    });

    test('결제·취소된 거래에는 더 할 일이 없다', () {
      final done = order(sellerConfirmed: true, buyerConfirmed: true, paid: true);
      expect(done.readyToPay, isFalse);
      expect(done.needsMyConfirmation, isFalse);

      final dropped = order(cancelled: true);
      expect(dropped.readyToPay, isFalse);
      expect(dropped.needsMyConfirmation, isFalse);
    });

    test('구버전 응답(새 필드 없음)은 결제 완료 건으로 깨지지 않게 읽힌다', () {
      final legacy = Order.fromJson(const {
        'orderId': 3,
        'artworkTitle': '옛 주문',
        'status': '결제 완료',
      });
      expect(legacy.paid, isFalse);
      expect(legacy.cancelled, isFalse);
      expect(legacy.viewerIsSeller, isFalse);
    });
  });

  testWidgets('예약 중인 작품은 판매 완료와 다른 칩을 보여준다', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: SoldOverlay(reserved: true)),
    ));
    expect(find.text('예약중'), findsOneWidget);
    expect(find.text('판매 완료'), findsNothing);

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: SoldOverlay()),
    ));
    expect(find.text('판매 완료'), findsOneWidget);
  });
}
