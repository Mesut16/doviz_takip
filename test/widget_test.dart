import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:doviz_takip/main.dart';

void main() {
  testWidgets('Home screen should display Döviz Takip', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('Döviz Takip'), findsOneWidget);
  });
}
