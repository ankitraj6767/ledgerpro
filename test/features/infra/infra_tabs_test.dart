import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/core/cache/dashboard_cache.dart';
import 'package:ledgerpro_mobile/data/repositories/infra_repository.dart';
import 'package:ledgerpro_mobile/features/infra/presentation/infra_tabs.dart';
import 'package:ledgerpro_mobile/shared/models/infra_models.dart';

void main() {
  testWidgets('expenses renders cached projects while live data loads', (
    tester,
  ) async {
    final pendingProjects = Completer<List<InfraProject>>();
    const project = InfraProject(
      id: 'project-1',
      organizationId: 'org-1',
      name: 'Highway Package 3',
      status: InfraProjectStatus.active,
    );
    const snapshot = DashboardSnapshot(
      userId: 'user-1',
      orgName: 'Test Organization',
      summary: InfraDashboardSummary(totalProjects: 1),
      projects: [project],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          projectsProvider.overrideWith((ref) => pendingProjects.future),
          cachedDashboardProvider.overrideWithValue(snapshot),
        ],
        child: const MaterialApp(home: GlobalExpensesScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Expenses'), findsOneWidget);
    expect(find.text('Highway Package 3'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
