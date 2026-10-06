import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/main.dart';

void main() {
  testWidgets('StaffApp smoke test renders initialization state', (WidgetTester tester) async {
    await tester.pumpWidget(const StaffApp());
    expect(find.byType(StaffApp), findsOneWidget);
  });
}
