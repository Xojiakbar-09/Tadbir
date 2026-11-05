import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadbir_go/src/features/home/presentation/page/home_page.dart';

void main() {
  testWidgets('HomePage renders', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    expect(find.byType(HomePage), findsOneWidget);
  });
}
