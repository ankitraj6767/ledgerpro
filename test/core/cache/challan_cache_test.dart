import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/core/cache/challan_cache.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_models.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_status.dart';
import 'package:ledgerpro_mobile/features/challans/domain/material_type.dart';

void main() {
  final challan = EPassChallan(
    id: 'challan-1',
    organizationId: 'org-1',
    projectId: 'project-1',
    financialYear: '2026-2027',
    challanNumber: 'BR2026001234',
    normalizedChallanNumber: 'BR2026001234',
    selectedMaterialType: ChallanMaterialType.sand,
    portalMineralName: 'Sand',
    quantity: 12.5,
    vehicleNumber: 'BR01GH4567',
    normalizedVehicleNumber: 'BR01GH4567',
    verificationStatus: ChallanVerificationStatus.portalCaptured,
    verificationMethod:
        ChallanVerificationMethod.webviewHumanVerification,
    projectName: 'Highway Package 3',
  );

  test('round-trips a user and organization scoped challan snapshot', () {
    const userId = 'user-1';
    const organizationId = 'org-1';
    final snapshot = ChallanCacheSnapshot(
      userId: userId,
      organizationId: organizationId,
      challans: [challan],
    );

    final restored = ChallanCacheSnapshot.fromJson(snapshot.toJson());

    expect(restored?.userId, userId);
    expect(restored?.organizationId, organizationId);
    expect(restored?.challans, [challan]);
  });

  test('ignores malformed rows without rejecting the cache', () {
    final json = ChallanCacheSnapshot(
      userId: 'user-1',
      organizationId: 'org-1',
      challans: [challan],
    ).toJson()
      ..['challans'] = [challan.toJson(), {'id': 'incomplete'}];

    final restored = ChallanCacheSnapshot.fromJson(json);

    expect(restored?.challans, [challan]);
  });
}
