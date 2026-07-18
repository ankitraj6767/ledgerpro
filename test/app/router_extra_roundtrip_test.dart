import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/shared/models/infra_models.dart';

/// Guards against the crash:
///   type '_Map<String, dynamic>' is not a subtype of type 'InfraProject?'
///
/// After Android state restoration, go_router hands a route's `extra` back as a
/// JSON `Map` instead of the original object. The router must reconstruct the
/// model from that map (mirroring `_projectFromExtra` / `_fundFromExtra`)
/// instead of hard-casting it. These tests prove the JSON round-trip works so
/// the reconstruction path is valid.
void main() {
  test('InfraProject survives a JSON (extra) round-trip', () {
    const project = InfraProject(
      id: 'p1',
      organizationId: 'o1',
      name: 'Bridge Project',
      totalEstimatedCostPaise: 10000000,
      totalInvestmentPaise: 4000000,
      totalGovtReceivedPaise: 1000000,
    );

    // Simulate go_router serialize -> restore.
    final restored = jsonDecode(jsonEncode(project.toJson()));
    expect(restored, isA<Map<String, dynamic>>());

    final rebuilt = InfraProject.fromJson(Map<String, dynamic>.from(restored));
    expect(rebuilt.id, project.id);
    expect(rebuilt.name, project.name);
    expect(rebuilt.totalEstimatedCostPaise, project.totalEstimatedCostPaise);
    expect(rebuilt, project);
  });

  test('GovernmentFund survives a JSON (extra) round-trip', () {
    const fund = GovernmentFund(
      id: 'f1',
      projectId: 'p1',
      departmentName: 'PWD',
      amountSanctionedPaise: 15000000,
      amountReceivedPaise: 7000000,
    );

    final restored = jsonDecode(jsonEncode(fund.toJson()));
    final rebuilt = GovernmentFund.fromJson(Map<String, dynamic>.from(restored));
    expect(rebuilt.id, fund.id);
    expect(rebuilt.departmentName, fund.departmentName);
    expect(rebuilt, fund);
  });
}
