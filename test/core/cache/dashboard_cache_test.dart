import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/core/cache/dashboard_cache.dart';
import 'package:ledgerpro_mobile/shared/models/infra_models.dart';

void main() {
  test('dashboard cache preserves returned investment totals', () {
    const snapshot = DashboardSnapshot(
      userId: 'user-1',
      orgName: 'Org',
      summary: InfraDashboardSummary(totalInvestmentPaise: 6000),
      projects: [
        InfraProject(
          id: 'project-1',
          organizationId: 'org-1',
          name: 'Project',
          totalInvestmentPaise: 9000,
          totalInvestmentReturnedPaise: 3000,
        ),
      ],
    );

    final restored = DashboardSnapshot.fromJson(snapshot.toJson());

    expect(restored, isNotNull);
    expect(restored!.projects.single.netInvestmentPaise, 6000);
  });

  test('dashboard cache rejects snapshots from the old gross-only schema', () {
    expect(
      DashboardSnapshot.fromJson({
        'userId': 'user-1',
        'orgName': 'Org',
        'summary': const InfraDashboardSummary().toJson(),
        'projects': const <Object>[],
      }),
      isNull,
    );
  });
}
