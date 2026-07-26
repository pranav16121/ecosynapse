import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ecosynapse/main.dart';
import 'package:ecosynapse/core/state/auth_state.dart';

void main() {
  testWidgets('Splash screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => AuthState())],
        child: const EcoSynapseApp(),
      ),
    );

    // Verify that EcoSynapse text is shown
    expect(find.text('EcoSynapse'), findsOneWidget);

    // Fast-forward the splash timer
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}
