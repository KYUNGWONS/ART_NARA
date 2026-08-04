import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:artnara/widgets/auction_countdown.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('HH:mm:ss 는 1초마다 줄어든다', (tester) async {
    await tester.pumpWidget(_wrap(const AuctionCountdown('00:00:10')));
    expect(find.text('00:00:10'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    expect(find.text('00:00:07'), findsOneWidget);
  });

  testWidgets('0이 되면 onExpired 를 한 번만 호출한다', (tester) async {
    var expired = 0;
    await tester.pumpWidget(_wrap(
      AuctionCountdown('00:00:02', onExpired: () => expired++),
    ));

    await tester.pump(const Duration(seconds: 5));
    expect(find.text('00:00:00'), findsOneWidget);
    expect(expired, 1);

    // 타이머가 멈췄으므로 더 지나도 다시 부르지 않는다.
    await tester.pump(const Duration(seconds: 3));
    expect(expired, 1);
  });

  testWidgets('D-n 형식은 정적으로 그대로 보여준다', (tester) async {
    await tester.pumpWidget(
        _wrap(const AuctionCountdown('D-3', prefix: '남은 시간 ')));
    expect(find.text('남은 시간 D-3'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('남은 시간 D-3'), findsOneWidget);
  });

  testWidgets('null 이면 아무것도 그리지 않는다', (tester) async {
    await tester.pumpWidget(_wrap(const AuctionCountdown(null)));
    expect(find.byType(Text), findsNothing);
  });
}
