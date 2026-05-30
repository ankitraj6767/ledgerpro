import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/app/app.dart';
import 'package:ledgerpro_mobile/app/router/app_router.dart';
import 'package:ledgerpro_mobile/core/security/app_session_controller.dart';

void main() {
  testWidgets('LedgerPro app starts with branded splash', (tester) async {
    // Use a controller that has not been initialized so the router guard keeps
    // the app on the splash screen (Supabase is not configured in tests).
    final controller = AppSessionController();
    final router = AppRouter.create(controller);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSessionControllerProvider.overrideWithValue(controller),
        ],
        child: LedgerProApp(router: router),
      ),
    );

    expect(find.text('LedgerPro Mobile'), findsOneWidget);
    expect(
      find.text('Secure mobile ledger for internal business books.'),
      findsOneWidget,
    );
  });
}
