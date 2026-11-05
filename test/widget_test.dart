import 'package:flutter_test/flutter_test.dart';
import 'package:tadbir_go/main.dart';
import 'package:tadbir_go/src/features/home/presentation/page/home_page.dart';

void main() {
  testWidgets('App renders HomePage smoke test', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(HomePage), findsOneWidget);
  });
}
