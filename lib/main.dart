import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'app/constants/supabase_config.dart';
import 'app/router/app_router.dart';
import 'core/cache/dashboard_cache.dart';
import 'core/security/app_session_controller.dart';

Future<void> main() async {
  // Run the whole app inside a guarded zone so that any uncaught asynchronous
  // error (realtime stream errors, connectivity channel errors, background
  // futures, plugin channel rejections, etc.) is logged instead of tearing
  // down the process. On desktop (Windows in particular) an unhandled error in
  // the root zone terminates the running executable, which surfaced as the app
  // "randomly crashing" mid-use and having to be reopened.
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Framework (build/layout/paint) errors: log and keep running instead of
      // letting them escalate.
      final previousOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        _logError(
          'FlutterError',
          details.exception,
          details.stack,
          context: details.context?.toDescription(),
        );
        if (kDebugMode) {
          previousOnError?.call(details);
        }
      };

      // Platform / engine-level async errors that would otherwise be unhandled.
      // Returning true marks them as handled so they don't crash the app.
      WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
        _logError('PlatformDispatcher', error, stack);
        return true;
      };

      if (SupabaseConfig.isConfigured) {
        try {
          await Supabase.initialize(
            url: SupabaseConfig.url,
            anonKey: SupabaseConfig.publishableKey,
            debug: false,
            authOptions: const FlutterAuthClientOptions(
              // Persist the session to disk and auto-refresh tokens so
              // returning users are not forced to log in again.
              authFlowType: AuthFlowType.pkce,
              autoRefreshToken: true,
            ),
          );
        } catch (error, stack) {
          // A blocked/offline network or corrupt persisted session must not
          // prevent the app from starting; the session controller falls back
          // to routing the user to login when Supabase is unavailable.
          _logError('Supabase.initialize', error, stack);
        }
      }

      // Build and initialize the session/lock controller before the first
      // frame so the router guard can decide login vs unlock vs home
      // synchronously. The dashboard cache is loaded in parallel (local file,
      // no network) so the home screen can render the last-known real data
      // immediately instead of empty placeholders.
      final sessionController = AppSessionController();
      final dashboardCache = DashboardCache();
      try {
        await Future.wait([
          sessionController.initialize(),
          dashboardCache.load(),
        ]);
      } catch (error, stack) {
        // Never block first render on startup work; degrade gracefully.
        _logError('startup', error, stack);
      }

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
    },
    (error, stack) => _logError('uncaughtZoneError', error, stack),
  );
}

void _logError(
  String source,
  Object error,
  StackTrace? stack, {
  String? context,
}) {
  developer.log(
    'Unhandled error from $source${context != null ? ' ($context)' : ''}',
    name: 'LedgerPro',
    error: error,
    stackTrace: stack,
  );
}
