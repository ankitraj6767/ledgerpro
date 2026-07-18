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

      // Build/layout exceptions in release builds are replaced by Flutter's
      // default `RenderErrorBox`, which paints a solid grey rectangle. When the
      // widget that throws sits high in the tree (a route's root Scaffold on
      // startup), that grey box fills the entire screen and looks like the app
      // "crashed" with a dead grey screen the user has to force-close. Replace
      // it with a safe, self-contained fallback that stays readable and offers
      // a way back into the app instead of the alarming grey void.
      ErrorWidget.builder = (FlutterErrorDetails details) {
        _logError(
          'ErrorWidget',
          details.exception,
          details.stack,
          context: details.context?.toDescription(),
        );
        return const _AppErrorFallback();
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
        // Bound the pre-first-frame work with a timeout. A platform channel
        // that hangs (flutter_secure_storage on some Android keystore states,
        // path_provider, or a stalled Supabase init) must never block runApp
        // indefinitely — that leaves a permanently blank launch window the
        // user has to force-close. On timeout we proceed with whatever state
        // has loaded; the router guard falls back to splash/login safely.
        await Future.wait([
          sessionController.initialize(),
          dashboardCache.load(),
        ]).timeout(const Duration(seconds: 8));
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

/// Safe, self-contained replacement for Flutter's default grey `RenderErrorBox`.
///
/// This is installed as [ErrorWidget.builder] so a build/layout exception —
/// which in release would otherwise paint a solid grey screen — instead shows
/// a readable, on-brand message. It deliberately depends on nothing but core
/// Flutter widgets and hardcoded colors, and wraps itself in [Directionality]
/// and [Material], because [ErrorWidget.builder] can be invoked for a subtree
/// that sits above (or outside) the app's `MaterialApp`/`Directionality`.
class _AppErrorFallback extends StatelessWidget {
  const _AppErrorFallback();

  static const _navy = Color(0xFF03152E);
  static const _gold = Color(0xFFD6A83A);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        color: _navy,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.refresh_rounded,
                    color: _gold,
                    size: 52,
                  ),
                  SizedBox(height: 18),
                  Text(
                    'Something needs a moment',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'This screen ran into a temporary problem. Please close and '
                    'reopen the app — your data is safe.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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
