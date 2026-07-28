import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unitrip/main.dart';

void main() {
  testWidgets('UniTrip app launches correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const UniTripApp());
    await tester.pumpAndSettle();

    // 앱 루트(MaterialApp)가 정상적으로 렌더링되는지 확인
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
