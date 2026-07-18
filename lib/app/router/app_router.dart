import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/security/app_session_controller.dart';
import '../../features/app_lock/presentation/app_lock_screen.dart';
import '../../features/app_lock/presentation/unlock_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/infra/presentation/infra_forms.dart';
import '../../features/infra/presentation/infra_home_screen.dart';
import '../../features/infra/presentation/infra_tabs.dart';
import '../../features/infra/presentation/project_detail_screen.dart';
import '../../features/infra/presentation/project_notes_screen.dart';
import '../../features/infra/presentation/project_reports_screen.dart';
import '../../features/infra/presentation/projects_list_screen.dart';
import '../../features/onboarding/presentation/organization_setup_screen.dart';
import '../../features/settings/presentation/audit_logs_screen.dart';
import '../../features/settings/presentation/customer_users_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/sync_queue_screen.dart';
import '../../shared/components/navdream_logo.dart';
import '../../shared/models/infra_models.dart';
import '../../shared/widgets/infra_shell.dart';
import '../constants/app_constants.dart';

/// Safely resolves a route's `extra` payload into an [InfraProject].
///
/// `extra` is normally the live object, but after Android state restoration
/// (app killed/backgrounded then resumed) go_router serializes it to JSON, so
/// on restore it comes back as a `Map<String, dynamic>`. Casting that Map
/// directly (`extra as InfraProject?`) throws and crashes the whole route.
/// This reconstructs the object from JSON when possible, and otherwise returns
/// null so the screen loads fresh data from its path id.
InfraProject? _projectFromExtra(Object? extra) {
  if (extra is InfraProject) return extra;
  if (extra is Map) {
    try {
      return InfraProject.fromJson(Map<String, dynamic>.from(extra));
    } catch (_) {
      return null;
    }
  }
  return null;
}

/// See [_projectFromExtra]: same safe handling for a [GovernmentFund] `extra`.
GovernmentFund? _fundFromExtra(Object? extra) {
  if (extra is GovernmentFund) return extra;
  if (extra is Map) {
    try {
      return GovernmentFund.fromJson(Map<String, dynamic>.from(extra));
    } catch (_) {
      return null;
    }
  }
  return null;
}

class AppRouter {
  const AppRouter._();

  static GoRouter create(AppSessionController session) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: session,
      redirect: (context, state) => _guard(session, state.matchedLocation),
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.otp,
          builder: (context, state) =>
              OtpScreen(phone: state.extra is String ? state.extra as String : null),
        ),
        GoRoute(
          path: AppRoutes.unlock,
          builder: (context, state) => const UnlockScreen(),
        ),
        GoRoute(
          path: AppRoutes.appLock,
          builder: (context, state) => const AppLockScreen(),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (context, state) => const OrganizationSetupScreen(),
        ),

        // ------------------------------------------------------------------
        // Bottom-nav shell. 
        // ------------------------------------------------------------------
        ShellRoute(
          builder: (context, state, child) => InfraShell(child: child),
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const InfraHomeScreen(),
            ),
            GoRoute(
              path: AppRoutes.projects,
              builder: (context, state) => const ProjectsListScreen(),
            ),
            GoRoute(
              path: AppRoutes.expenses,
              builder: (context, state) => const GlobalExpensesScreen(),
            ),
            GoRoute(
              path: AppRoutes.reports,
              builder: (context, state) => const GlobalReportsScreen(),
            ),
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),

        // ------------------------------------------------------------------
        // Projects (full-screen, pushed over the shell)
        // ------------------------------------------------------------------
        GoRoute(
          path: AppRoutes.newProject,
          builder: (context, state) => const ProjectFormScreen(),
        ),
        GoRoute(
          path: AppRoutes.editProjectPath,
          builder: (context, state) =>
              ProjectFormScreen(project: _projectFromExtra(state.extra)),
        ),
        GoRoute(
          path: AppRoutes.projectDetailPath,
          builder: (context, state) => ProjectDetailScreen(
            projectId: state.pathParameters['projectId']!,
            initialProject: _projectFromExtra(state.extra),
            initialTabIndex:
                int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0,
          ),
        ),
        GoRoute(
          path: AppRoutes.newInvestmentPath,
          builder: (context, state) {
            final project = _projectFromExtra(state.extra);
            if (project == null) return const _MissingExtraScreen();
            return InvestmentFormScreen(project: project);
          },
        ),
        GoRoute(
          path: AppRoutes.newGovtFundPath,
          builder: (context, state) {
            final project = _projectFromExtra(state.extra);
            if (project == null) return const _MissingExtraScreen();
            return GovtFundFormScreen(project: project);
          },
        ),
        GoRoute(
          path: AppRoutes.newGovtReceiptPath,
          builder: (context, state) {
            final fund = _fundFromExtra(state.extra);
            if (fund == null) return const _MissingExtraScreen();
            return GovtReceiptFormScreen(fund: fund);
          },
        ),
        GoRoute(
          path: AppRoutes.newExpensePath,
          builder: (context, state) {
            final project = _projectFromExtra(state.extra);
            if (project == null) return const _MissingExtraScreen();
            return ExpenseFormScreen(project: project);
          },
        ),
        GoRoute(
          path: AppRoutes.projectNotesPath,
          builder: (context, state) => ProjectNotesScreen(
            projectId: state.pathParameters['projectId']!,
            project: _projectFromExtra(state.extra),
          ),
        ),
        GoRoute(
          path: AppRoutes.projectReportsPath,
          builder: (context, state) => ProjectReportsScreen(
            projectId: state.pathParameters['projectId']!,
            project: _projectFromExtra(state.extra),
          ),
        ),

        // ------------------------------------------------------------------
        // Settings / misc
        // ------------------------------------------------------------------
        GoRoute(
          path: AppRoutes.settings,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: AppRoutes.customers,
          builder: (context, state) => const CustomerUsersScreen(),
        ),
        GoRoute(
          path: AppRoutes.auditLogs,
          builder: (context, state) => const AuditLogsScreen(),
        ),
        GoRoute(
          path: AppRoutes.syncQueue,
          builder: (context, state) => const SyncQueueScreen(),
        ),
      ],
    );
  }

  static const _publicRoutes = <String>{
    AppRoutes.login,
    AppRoutes.otp,
    AppRoutes.onboarding,
  };

  static String? _guard(AppSessionController session, String location) {
    if (!session.isInitialized) {
      return location == AppRoutes.splash ? null : AppRoutes.splash;
    }

    if (location == AppRoutes.splash) {
      if (!session.isAuthenticated) return AppRoutes.login;
      if (!session.hasPin) return AppRoutes.appLock;
      if (!session.isUnlocked) return AppRoutes.unlock;
      return AppRoutes.home;
    }

    final authed = session.isAuthenticated;
    if (!authed) {
      return _publicRoutes.contains(location) ? null : AppRoutes.login;
    }
    if (!session.hasPin) {
      return location == AppRoutes.appLock ? null : AppRoutes.appLock;
    }
    if (!session.isUnlocked) {
      return location == AppRoutes.unlock ? null : AppRoutes.unlock;
    }
    if (location == AppRoutes.login || location == AppRoutes.unlock) {
      return AppRoutes.home;
    }
    return null;
  }
}

class _MissingExtraScreen extends StatelessWidget {
  const _MissingExtraScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unavailable')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline, size: 44),
              const SizedBox(height: 12),
              const Text(
                'This screen needs to be opened from a project.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.go(AppRoutes.projects),
                child: const Text('Go to Projects'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03152E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const NavdreamLogo(
                size: 88,
                borderRadius: BorderRadius.all(Radius.circular(26)),
                showBorder: true,
                showShadow: true,
              ),
              const SizedBox(height: 20),
              Text(
                AppConstants.appName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                AppConstants.appTagline,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const Spacer(),
              const LinearProgressIndicator(
                minHeight: 4,
                color: Color(0xFFD6A83A),
                backgroundColor: Colors.white24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
