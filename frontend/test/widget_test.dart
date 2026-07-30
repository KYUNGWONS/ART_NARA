import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:artnara/main.dart';

void main() {
  testWidgets('ArtNara app launches correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const ArtNaraApp());
    await tester.pumpAndSettle();

    // 앱 루트(MaterialApp)가 정상적으로 렌더링되는지 확인
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
