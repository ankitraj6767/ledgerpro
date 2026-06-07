import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/infra_theme.dart';
import '../../../data/repositories/material_repository.dart';
import '../../../shared/components/infra_components.dart';
import '../../../shared/models/material_models.dart';

class MaterialStockScreen extends ConsumerWidget {
  const MaterialStockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => _ReportScaffold(
    title: 'Warehouse Stock',
    child: ref
        .watch(warehouseStockSummaryProvider)
        .when(
          loading: _loading,
          error: _error,
          data: (rows) => _list(
            rows,
            (WarehouseStockRow row) => ListTile(
              leading: const Icon(
                Icons.inventory_2_outlined,
                color: InfraColors.royalBlue,
              ),
              title: Text(row.materialName),
              subtitle: Text(
                'Received ${formatQuantity(row.totalReceived)} • Issued ${formatQuantity(row.totalIssued)}',
              ),
              trailing: Text(
                '${formatQuantity(row.remainingStock)} ${row.unit}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
  );
}

class MaterialIssuesScreen extends ConsumerWidget {
  const MaterialIssuesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => _ReportScaffold(
    title: 'Material Issues',
    child: ref
        .watch(recentMaterialIssuesProvider)
        .when(
          loading: _loading,
          error: _error,
          data: (rows) => _list(
            rows,
            (RecentMaterialIssue row) => ListTile(
              leading: const Icon(Icons.outbox_outlined),
              title: Text('${row.managerName} • ${row.schoolName}'),
              subtitle: Text(row.summaryText),
              trailing: Text(DateFormat('dd MMM').format(row.issueDate)),
            ),
          ),
        ),
  );
}

class LowStockScreen extends ConsumerWidget {
  const LowStockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => _ReportScaffold(
    title: 'Low Stock',
    child: ref
        .watch(lowStockAlertsProvider)
        .when(
          loading: _loading,
          error: _error,
          data: (rows) => _list(
            rows,
            (LowStockAlert row) => ListTile(
              leading: const Icon(
                Icons.warning_amber_rounded,
                color: InfraColors.red,
              ),
              title: Text(row.materialName),
              subtitle: Text(row.alertLevel.toUpperCase()),
              trailing: Text(
                '${formatQuantity(row.remainingStock)} ${row.unit}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
  );
}

class SchoolMaterialReportScreen extends ConsumerWidget {
  const SchoolMaterialReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => _ReportScaffold(
    title: 'School Material Report',
    child: ref
        .watch(schoolRequirementIssueProvider)
        .when(
          loading: _loading,
          error: _error,
          data: (rows) => _list(
            rows,
            (SchoolRequirementIssueRow row) => ListTile(
              leading: const Icon(Icons.school_outlined),
              title: Text(row.schoolName),
              subtitle: Text(
                '${formatQuantity(row.issuedPercent)}% issued • ${formatQuantity(row.pendingPercent)}% pending',
              ),
              trailing: Text(
                row.status.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
  );
}

class ManagerMaterialReportScreen extends ConsumerWidget {
  const ManagerMaterialReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => _ReportScaffold(
    title: 'Manager Material Report',
    child: ref
        .watch(managerMaterialIssueSummaryProvider)
        .when(
          loading: _loading,
          error: _error,
          data: (rows) => _list(
            rows,
            (ManagerMaterialIssueRow row) => ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text('${row.managerName} • ${row.schoolName}'),
              subtitle: Text(row.materialName),
              trailing: Text(
                '${formatQuantity(row.issuedQuantity)} ${row.unit}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
  );
}

class _ReportScaffold extends StatelessWidget {
  const _ReportScaffold({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: child,
  );
}

Widget _loading() => const Center(child: CircularProgressIndicator());

Widget _error(Object error, StackTrace _) =>
    ErrorStateView(message: 'Could not load report: $error');

Widget _list<T>(List<T> rows, Widget Function(T row) builder) {
  if (rows.isEmpty) {
    return const EmptyState(
      icon: Icons.inventory_2_outlined,
      title: 'No material data yet',
    );
  }
  return ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: rows.length,
    separatorBuilder: (_, _) => const Divider(height: 1),
    itemBuilder: (context, index) => Card(child: builder(rows[index])),
  );
}
