import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/app_lock/presentation/app_lock_screen.dart';
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
import '../../features/settings/presentation/more_screen.dart';
import '../../features/staff/presentation/staff_screen.dart';
import '../../features/transactions/presentation/add_transaction_screen.dart';
import '../../features/transactions/presentation/transaction_detail_screen.dart';
import '../../shared/widgets/ledger_shell.dart';
import '../../shared/widgets/module_screen.dart';
import '../constants/app_constants.dart';

class AppRouter {
  const AppRouter._();

  static final router = GoRouter(
    initialLocation: AppRoutes.splash,
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
        builder: (context, state) => const AddPartyScreen(),
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
        builder: (context, state) => const InvoicePreviewScreen(),
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
        builder: (context, state) => const ModuleScreen(
          title: 'Audit logs',
          icon: Icons.manage_search_outlined,
          summary:
              'Owner-visible activity history for edits, reversals, reminders, and staff actions.',
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const ModuleScreen(
          title: 'Settings',
          icon: Icons.settings_outlined,
          summary:
              'Business profile, books, language, app lock, GST, UPI, and notification settings.',
        ),
      ),
      GoRoute(
        path: AppRoutes.businessCard,
        builder: (context, state) => const ModuleScreen(
          title: 'Business card',
          icon: Icons.badge_outlined,
          summary:
              'Share a clean LedgerPro business card with phone, address, GSTIN, and UPI details.',
        ),
      ),
      GoRoute(
        path: AppRoutes.syncQueue,
        builder: (context, state) => const ModuleScreen(
          title: 'Offline sync queue',
          icon: Icons.sync_outlined,
          summary:
              'Pending local mutations sync in the order businesses, books, parties, transactions, attachments, reminders, and reports.',
        ),
      ),
    ],
  );
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) context.go(AppRoutes.login);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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
