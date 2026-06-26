import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'app/constants/supabase_config.dart';
import 'app/router/app_router.dart';
import 'core/cache/dashboard_cache.dart';
import 'core/security/app_session_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.publishableKey,
      debug: false,
      authOptions: const FlutterAuthClientOptions(
        // Persist the session to disk and auto-refresh tokens so returning
        // users are not forced to log in again.
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: true,
      ),
    );
  }

  // Build and initialize the session/lock controller before the first frame so
  // the router guard can decide login vs unlock vs home synchronously. The
  // dashboard cache is loaded in parallel (local file, no network) so the home
  // screen can render the last-known real data immediately instead of empty
  // placeholders.
  final sessionController = AppSessionController();
  final dashboardCache = DashboardCache();
  await Future.wait([sessionController.initialize(), dashboardCache.load()]);

  final router = AppRouter.create(sessionController);

  runApp(
    ProviderScope(
      overrides: [
        appSessionControllerProvider.overrideWithValue(sessionController),
        dashboardCacheProvider.overrideWithValue(dashboardCache),
      ],
      child: LedgerProApp(router: router),
    ),
  );
}
