import 'package:flutter_test/flutter_test.dart';
import 'package:checkerchecks/main.dart';

void main() {
  testWidgets('CheckerChecksApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CheckerChecksApp());
    expect(find.byType(CheckerChecksApp), findsOneWidget);
  });
}
