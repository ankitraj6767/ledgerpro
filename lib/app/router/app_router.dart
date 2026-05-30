import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/security/app_session_controller.dart';
import '../../features/app_lock/presentation/app_lock_screen.dart';
import '../../features/app_lock/presentation/unlock_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/dashboard/presentation/home_dashboard_screen.dart';
import '../../features/inventory/presentation/inventory_screen.dart';
import '../../features/invoices/presentation/invoice_screen.dart';
import '../../features/onboarding/presentation/business_setup_screen.dart';
import '../../features/onboarding/presentation/owner_onboarding_screen.dart';
import '../../features/parties/presentation/add_party_screen.dart';
import '../../features/parties/presentation/parties_list_screen.dart';
import '../../features/parties/presentation/party_detail_screen.dart';
import '../../features/payments/presentation/payment_qr_screen.dart';
import '../../features/reminders/presentation/reminders_screen.dart';
import '../../features/reports/presentation/reports_home_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/settings/presentation/audit_logs_screen.dart';
import '../../features/settings/presentation/business_card_screen.dart';
import '../../features/settings/presentation/more_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/sync_queue_screen.dart';
import '../../features/staff/presentation/staff_screen.dart';
import '../../features/transactions/presentation/add_transaction_screen.dart';
import '../../features/transactions/presentation/transaction_detail_screen.dart';
import '../../shared/widgets/ledger_shell.dart';
import '../../shared/widgets/module_screen.dart';
import '../../shared/models/ledger_models.dart';
import '../constants/app_constants.dart';

class AppRouter {
  const AppRouter._();

  /// Builds the app router with an auth + app-lock guard.
  ///
  /// Routing rules (in priority order):
  /// 1. While the session controller is still initializing → splash.
  /// 2. Demo mode → allow app shell without a session.
  /// 3. No Supabase session → login (and its sub-flows: otp / onboarding).
  /// 4. Session but no PIN configured → force app-lock setup once.
  /// 5. Session + PIN but locked → unlock screen (PIN / biometric).
  /// 6. Otherwise → app shell.
  static GoRouter create(AppSessionController session) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: session,
      redirect: (context, state) =>
          _guard(session, state.matchedLocation),
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
          builder: (context, state) => const OtpScreen(),
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
        builder: (context, state) => const OwnerOnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.businessSetup,
        builder: (context, state) => const BusinessSetupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => LedgerShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeDashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.parties,
            builder: (context, state) => const PartiesListScreen(),
          ),
          GoRoute(
            path: AppRoutes.add,
            builder: (context, state) => const AddTransactionScreen(),
          ),
          GoRoute(
            path: AppRoutes.reports,
            builder: (context, state) => const ReportsHomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.more,
            builder: (context, state) => const MoreScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.addParty,
        builder: (context, state) =>
            AddPartyScreen(party: state.extra as Party?),
      ),
      GoRoute(
        path: '/parties/:partyId',
        builder: (context, state) =>
            PartyDetailScreen(partyId: state.pathParameters['partyId']!),
      ),
      GoRoute(
        path: '/transactions/:transactionId',
        builder: (context, state) => TransactionDetailScreen(
          transactionId: state.pathParameters['transactionId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.reminders,
        builder: (context, state) => const RemindersScreen(),
      ),
      GoRoute(
        path: AppRoutes.bulkReminder,
        builder: (context, state) => const BulkReminderScreen(),
      ),
      GoRoute(
        path: AppRoutes.paymentQr,
        builder: (context, state) => const PaymentQrScreen(),
      ),
      GoRoute(
        path: AppRoutes.invoices,
        builder: (context, state) => const InvoiceListScreen(),
      ),
      GoRoute(
        path: AppRoutes.createInvoice,
        builder: (context, state) => const CreateInvoiceScreen(),
      ),
      GoRoute(
        path: AppRoutes.invoicePreview,
        builder: (context, state) =>
            InvoicePreviewScreen(invoice: state.extra as Invoice?),
      ),
      GoRoute(
        path: AppRoutes.inventory,
        builder: (context, state) => const InventoryListScreen(),
      ),
      GoRoute(
        path: AppRoutes.addProduct,
        builder: (context, state) => const AddProductScreen(),
      ),
      GoRoute(
        path: AppRoutes.reportDetail,
        builder: (context, state) => const ReportDetailScreen(),
      ),
      GoRoute(
        path: AppRoutes.exportCenter,
        builder: (context, state) => const ModuleScreen(
          title: 'Export center',
          icon: Icons.ios_share_outlined,
          summary:
              'PDF and CSV exports are queued here for offline-safe sharing.',
        ),
      ),
      GoRoute(
        path: AppRoutes.staff,
        builder: (context, state) => const StaffScreen(),
      ),
      GoRoute(
        path: AppRoutes.auditLogs,
        builder: (context, state) => const AuditLogsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.businessCard,
        builder: (context, state) => const BusinessCardScreen(),
      ),
      GoRoute(
        path: AppRoutes.syncQueue,
        builder: (context, state) => const SyncQueueScreen(),
      ),
      ],
    );
  }

  /// Locations reachable without a Supabase session.
  ///
  /// [AppRoutes.splash] is intentionally NOT included: it is a transient
  /// loading screen, so once the controller is initialized the guard must
  /// always redirect away from it (to login / unlock / app-lock / home).
  static const _publicRoutes = <String>{
    AppRoutes.login,
    AppRoutes.otp,
    AppRoutes.onboarding,
    AppRoutes.businessSetup,
  };

  static String? _guard(AppSessionController session, String location) {
    // Wait for the controller to finish loading lock state. While not yet
    // initialized, hold on the splash screen.
    if (!session.isInitialized) {
      return location == AppRoutes.splash ? null : AppRoutes.splash;
    }

    // Once initialized, the splash screen is never a valid resting place.
    // Resolve it to the correct destination based on auth + lock state.
    if (location == AppRoutes.splash) {
      if (session.isDemoMode) return AppRoutes.home;
      if (!session.isAuthenticated) return AppRoutes.login;
      if (!session.hasPin) return AppRoutes.appLock;
      if (!session.isUnlocked) return AppRoutes.unlock;
      return AppRoutes.home;
    }

    // Demo workspace: no session required, but block the auth/lock routes.
    if (session.isDemoMode) {
      if (location == AppRoutes.login ||
          location == AppRoutes.unlock ||
          location == AppRoutes.splash) {
        return AppRoutes.home;
      }
      return null;
    }

    final authed = session.isAuthenticated;

    // Not signed in → only public routes are allowed.
    if (!authed) {
      return _publicRoutes.contains(location) ? null : AppRoutes.login;
    }

    // Signed in but no PIN configured → force one-time app-lock setup.
    if (!session.hasPin) {
      return location == AppRoutes.appLock ? null : AppRoutes.appLock;
    }

    // Signed in with a PIN but currently locked → require unlock.
    if (!session.isUnlocked) {
      return location == AppRoutes.unlock ? null : AppRoutes.unlock;
    }

    // Fully authenticated and unlocked: keep users out of the gate screens.
    if (location == AppRoutes.login || location == AppRoutes.unlock) {
      return AppRoutes.home;
    }
    return null;
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Secure mobile ledger for internal business books.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
              const LinearProgressIndicator(minHeight: 4),
            ],
          ),
        ),
      ),
    );
  }
}
