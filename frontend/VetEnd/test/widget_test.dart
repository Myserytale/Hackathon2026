import 'package:flutter_test/flutter_test.dart';
import 'package:vet_portal/main.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VetPortalApp());
    expect(find.text('ROeID'), findsOneWidget);
  });
}
