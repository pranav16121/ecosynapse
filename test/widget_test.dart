import 'package:flutter_test/flutter_test.dart';
import 'package:ecosynapse/main.dart';

void main() {
  testWidgets('EcoSynapse smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our title and subtitle are present.
    expect(find.text('EcoSynapse'), findsAtLeastNWidgets(1));
    expect(find.text('Smart Waste. Smarter Communities.'), findsOneWidget);
  });
}
