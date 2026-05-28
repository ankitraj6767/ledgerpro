import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../app/constants/app_constants.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/money/money.dart';
import '../../../data/repositories/demo_ledger_provider.dart';
import '../../../shared/components/metric_card.dart';
import '../../../shared/components/quick_action_button.dart';
import '../../../shared/components/sync_badge.dart';
import '../../../shared/models/ledger_models.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);
    final businessName = ref.watch(businessNameProvider);
    final parties = ref.watch(demoPartiesProvider);
    final transactions = ref.watch(demoTransactionsProvider);
    final netBalance = summary.totalReceivablePaise - summary.totalPayablePaise;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(businessName),
            Text(
              'Main book · INR',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.graphite,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Search',
            onPressed: () => context.push(AppRoutes.search),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            tooltip: 'Sync queue',
            onPressed: () => context.push(AppRoutes.syncQueue),
            icon: const Icon(Icons.sync_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            Future<void>.delayed(const Duration(milliseconds: 450)),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _OfflineBanner(pendingCount: summary.pendingSyncItems),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Net balance',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Money.fromPaise(netBalance).formatInr(signed: true),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: netBalance >= 0
                            ? AppTheme.emerald
                            : AppTheme.crimson,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _MiniBalance(
                            label: 'You will get',
                            value: Money.fromPaise(
                              summary.totalReceivablePaise,
                            ).formatInr(),
                            color: AppTheme.emerald,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MiniBalance(
                            label: 'You have to give',
                            value: Money.fromPaise(
                              summary.totalPayablePaise,
                            ).formatInr(),
                            color: AppTheme.crimson,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.35,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                MetricCard(
                  label: 'Today collection',
                  value: Money.fromPaise(
                    summary.todayCollectionPaise,
                  ).formatInr(),
                  icon: Icons.payments_outlined,
                  color: AppTheme.emerald,
                ),
                MetricCard(
                  label: 'Credit given',
                  value: Money.fromPaise(
                    summary.todayCreditGivenPaise,
                  ).formatInr(),
                  icon: Icons.north_east_outlined,
                  color: AppTheme.brass,
                ),
                MetricCard(
                  label: 'Overdue',
                  value: '${summary.overdueParties}',
                  icon: Icons.alarm_outlined,
                  color: AppTheme.crimson,
                  subtitle: 'customers',
                ),
                MetricCard(
                  label: 'Low stock',
                  value: '${summary.lowStockItems}',
                  icon: Icons.inventory_2_outlined,
                  color: AppTheme.teal,
                  subtitle: 'items',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Quick actions',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  QuickActionButton(
                    icon: Icons.person_add_alt_1_outlined,
                    label: 'Add customer',
                    onPressed: () => context.push(AppRoutes.addParty),
                    color: AppTheme.teal,
                  ),
                  QuickActionButton(
                    icon: Icons.add_card_outlined,
                    label: 'Add entry',
                    onPressed: () => context.go(AppRoutes.add),
                    color: AppTheme.emerald,
                  ),
                  QuickActionButton(
                    icon: Icons.mark_chat_unread_outlined,
                    label: 'Reminder',
                    onPressed: () => context.push(AppRoutes.reminders),
                    color: AppTheme.brass,
                  ),
                  QuickActionButton(
                    icon: Icons.receipt_long_outlined,
                    label: 'Invoice',
                    onPressed: () => context.push(AppRoutes.createInvoice),
                    color: AppTheme.crimson,
                  ),
                  QuickActionButton(
                    icon: Icons.inventory_outlined,
                    label: 'Product',
                    onPressed: () => context.push(AppRoutes.addProduct),
                    color: AppTheme.teal,
                  ),
                  QuickActionButton(
                    icon: Icons.picture_as_pdf_outlined,
                    label: 'Report',
                    onPressed: () => context.go(AppRoutes.reports),
                    color: AppTheme.emerald,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Recent transactions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push(AppRoutes.reportDetail),
                  child: const Text('View all'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (transactions.isEmpty)
              const _DashboardSkeleton()
            else
              ...transactions.map((entry) {
                final party = parties.firstWhere((p) => p.id == entry.partyId);
                return Card(
                  child: ListTile(
                    onTap: () => context.push('/transactions/${entry.id}'),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.12),
                      child: Icon(
                        entry.type == TransactionType.youGot
                            ? Icons.south_west
                            : Icons.north_east,
                        color: entry.type == TransactionType.youGot
                            ? AppTheme.emerald
                            : AppTheme.brass,
                      ),
                    ),
                    title: Text(
                      party.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(entry.note ?? entry.type.name),
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Money.fromPaise(entry.amountPaise).formatInr(),
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        SyncBadge(status: entry.syncStatus),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _MiniBalance extends StatelessWidget {
  const _MiniBalance({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.pendingCount});

  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.brass.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.offline_bolt_outlined, color: AppTheme.brass),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              pendingCount == 0
                  ? 'All ledger entries are synced.'
                  : '$pendingCount local change${pendingCount == 1 ? '' : 's'} waiting for sync.',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8E2D7),
      highlightColor: Colors.white,
      child: Column(
        children: List.generate(
          3,
          (index) => Container(
            height: 72,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
