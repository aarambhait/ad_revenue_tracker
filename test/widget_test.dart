import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ad_revenue_tracker/main.dart';
import 'package:ad_revenue_tracker/services/app_state.dart';

void main() {
  testWidgets('App starts on login screen and shows Google sign in button', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const AdTrackerApp(),
      ),
    );

    // Settle any pending mock data loading timers by advancing the virtual clock
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    // Verify that the login page elements exist
    expect(find.text('AdTracker'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
  });
}
