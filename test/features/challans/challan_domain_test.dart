import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_models.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_portal.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_status.dart';
import 'package:ledgerpro_mobile/features/challans/domain/material_type.dart';
import 'package:ledgerpro_mobile/shared/models/infra_models.dart';

void main() {
  group('FinancialYear', () {
    test('current year rolls over on 1 April', () {
      expect(FinancialYear.current(DateTime(2026, 4, 1)), '2026-2027');
      expect(FinancialYear.current(DateTime(2026, 3, 31)), '2025-2026');
      expect(FinancialYear.current(DateTime(2026, 12, 31)), '2026-2027');
      expect(FinancialYear.current(DateTime(2027, 1, 1)), '2026-2027');
    });

    test('options are derived from the clock, never hard-coded', () {
      final options = FinancialYear.options(now: DateTime(2026, 7, 25));

      expect(options.first, '2027-2028');
      expect(options, contains('2026-2027'));
      expect(options, contains('2021-2022'));
      expect(options.length, 7);

      // A different clock produces a different list — nothing is pinned to 2026.
      final later = FinancialYear.options(now: DateTime(2031, 7, 25));
      expect(later, contains('2031-2032'));
      expect(later, isNot(contains('2021-2022')));
    });

    test('the current year is always selectable', () {
      for (final month in List.generate(12, (i) => i + 1)) {
        final now = DateTime(2026, month, 15);
        expect(
          FinancialYear.options(now: now),
          contains(FinancialYear.current(now)),
        );
      }
    });
  });

  group('material matching', () {
    test('recognizes English and Hindi mineral synonyms', () {
      expect(
        ChallanMaterialType.sand.matchesPortalMineral('Sand (Balu)'),
        isTrue,
      );
      expect(ChallanMaterialType.sand.matchesPortalMineral('बालू'), isTrue);
      expect(
        ChallanMaterialType.aggregate.matchesPortalMineral('Stone Chips'),
        isTrue,
      );
      expect(
        ChallanMaterialType.gitti.matchesPortalMineral('Stone Chips'),
        isTrue,
      );
      expect(
        ChallanMaterialType.balu.matchesPortalMineral('SAND (BALU)'),
        isTrue,
      );
      expect(
        ChallanMaterialType.boulder.matchesPortalMineral('Boulder & Grit'),
        isTrue,
      );
      expect(ChallanMaterialType.stone.matchesPortalMineral('पत्थर'), isTrue);
    });

    test('flags a genuine mismatch', () {
      expect(ChallanMaterialType.sand.matchesPortalMineral('Brick'), isFalse);
      expect(ChallanMaterialType.brick.matchesPortalMineral('Sand'), isFalse);
    });

    test('"other" and unknown minerals never trigger a false warning', () {
      expect(
        ChallanMaterialType.other.matchesPortalMineral('Anything'),
        isTrue,
      );
      expect(ChallanMaterialType.sand.matchesPortalMineral(null), isTrue);
      expect(ChallanMaterialType.sand.matchesPortalMineral(''), isTrue);
    });

    test('round-trips through the database value', () {
      for (final material in ChallanMaterialType.values) {
        expect(ChallanMaterialTypeMapping.fromDb(material.dbValue), material);
      }
      expect(ChallanMaterialTypeMapping.fromDb(null), isNull);
      expect(ChallanMaterialTypeMapping.fromDb('unknown'), isNull);
    });
  });

  group('status serialization', () {
    test('every status round-trips and matches the DB check constraint', () {
      const allowed = {
        'portal_captured',
        'manual_unverified',
        'official_api_verified',
        'invalid',
        'expired',
      };
      for (final status in ChallanVerificationStatus.values) {
        expect(allowed, contains(status.dbValue));
        expect(ChallanVerificationStatusMapping.fromDb(status.dbValue), status);
      }
    });

    test('every method round-trips and matches the DB check constraint', () {
      const allowed = {
        'webview_human_verification',
        'manual_entry',
        'official_api',
      };
      for (final method in ChallanVerificationMethod.values) {
        expect(allowed, contains(method.dbValue));
        expect(ChallanVerificationMethodMapping.fromDb(method.dbValue), method);
      }
    });

    test('unknown values degrade to the least-trusted status', () {
      expect(
        ChallanVerificationStatusMapping.fromDb('something_new'),
        ChallanVerificationStatus.manualUnverified,
      );
      expect(
        ChallanVerificationMethodMapping.fromDb(null),
        ChallanVerificationMethod.manualEntry,
      );
    });

    test('no status is labelled a bare "verified"', () {
      for (final status in ChallanVerificationStatus.values) {
        expect(status.label.toLowerCase(), isNot('verified'));
      }
    });
  });

  group('draft', () {
    EPassChallanDraft draft({
      ChallanMaterialType? material,
      String mineral = 'Sand',
      String challan = 'br-2026/77',
    }) => EPassChallanDraft(
      projectId: 'project-1',
      financialYear: '2026-2027',
      challanNumber: challan,
      selectedMaterialType: material,
      payload: CapturedPortalPayload(mineralName: mineral),
    );

    test('normalizes the challan number for comparison', () {
      expect(draft().normalizedChallanNumber, 'BR202677');
    });

    test('detects a material mismatch without overwriting either value', () {
      final mismatch = draft(
        material: ChallanMaterialType.brick,
        mineral: 'Sand',
      );

      expect(mismatch.hasMaterialMismatch, isTrue);
      // Both values survive.
      expect(mismatch.selectedMaterialType, ChallanMaterialType.brick);
      expect(mismatch.payload.mineralName, 'Sand');
    });

    test('no mismatch when the material agrees or is unset', () {
      expect(
        draft(
          material: ChallanMaterialType.sand,
          mineral: 'Sand',
        ).hasMaterialMismatch,
        isFalse,
      );
      expect(draft().hasMaterialMismatch, isFalse);
    });
  });

  group('mandatory field validation', () {
    test('a complete payload passes', () {
      final payload = CapturedPortalPayload(
        challanNumber: 'BR1',
        challanDate: DateTime.utc(2026, 5, 1),
        vehicleNumber: 'BR01AA1111',
        mineralName: 'Sand',
        quantity: 10,
      );

      expect(payload.hasAllMandatoryFields, isTrue);
      expect(payload.missingMandatoryFields, isEmpty);
    });

    test('each missing mandatory field is named', () {
      const payload = CapturedPortalPayload();

      expect(
        payload.missingMandatoryFields,
        CapturedPortalPayload.mandatoryFieldLabels,
      );
    });

    test('a zero or negative quantity counts as missing', () {
      final zero = CapturedPortalPayload(
        challanNumber: 'BR1',
        challanDate: DateTime.utc(2026, 5, 1),
        vehicleNumber: 'BR01AA1111',
        mineralName: 'Sand',
        quantity: 0,
      );

      expect(zero.missingMandatoryFields, contains('quantity'));
    });
  });

  group('challan display', () {
    test('quantity drops trailing zeros', () {
      EPassChallan challan(double quantity, [String unit = 'MT']) =>
          EPassChallan(
            id: 'c',
            organizationId: 'o',
            projectId: 'p',
            financialYear: '2026-2027',
            challanNumber: 'BR1',
            normalizedChallanNumber: 'BR1',
            portalMineralName: 'Sand',
            vehicleNumber: 'BR01AA1111',
            normalizedVehicleNumber: 'BR01AA1111',
            quantity: quantity,
            quantityUnit: unit,
          );

      expect(challan(30).quantityLabel, '30 MT');
      expect(challan(12.5).quantityLabel, '12.5 MT');
      expect(challan(8.25, 'CUM').quantityLabel, '8.25 CUM');
    });
  });

  group('ChallanFilter', () {
    test('reports which filters are active', () {
      expect(const ChallanFilter().isActive, isFalse);
      expect(const ChallanFilter(query: '  ').isActive, isFalse);
      expect(const ChallanFilter(query: 'BR1').isActive, isTrue);
      expect(
        const ChallanFilter(
          query: 'BR1',
          projectId: 'p',
          materialType: ChallanMaterialType.sand,
        ).activeCount,
        3,
      );
      expect(
        const ChallanFilter(portal: ChallanPortal.jharkhand).activeCount,
        1,
      );
    });
  });

  group('OrgPermissions challan gating mirrors RLS', () {
    test('owner and manager can do everything', () {
      for (final role in [OrgMemberRole.owner, OrgMemberRole.manager]) {
        final permissions = OrgPermissions(role);
        expect(permissions.canViewChallans, isTrue);
        expect(permissions.canAddChallan, isTrue);
        expect(permissions.canDeleteChallan, isTrue);
        expect(permissions.canExportChallans, isTrue);
      }
    });

    test('accountant can view, add and export but not archive', () {
      const permissions = OrgPermissions(OrgMemberRole.accountant);

      expect(permissions.canViewChallans, isTrue);
      expect(permissions.canAddChallan, isTrue);
      expect(permissions.canExportChallans, isTrue);
      expect(permissions.canDeleteChallan, isFalse);
    });

    test('site staff can view and add but not archive or export', () {
      const permissions = OrgPermissions(OrgMemberRole.siteStaff);

      expect(permissions.canViewChallans, isTrue);
      expect(permissions.canAddChallan, isTrue);
      expect(permissions.canDeleteChallan, isFalse);
      expect(permissions.canExportChallans, isFalse);
    });

    test('viewer and customer are read-only', () {
      for (final role in [OrgMemberRole.viewer, OrgMemberRole.customer]) {
        final permissions = OrgPermissions(role);
        expect(permissions.canViewChallans, isTrue);
        expect(permissions.canAddChallan, isFalse);
        expect(permissions.canDeleteChallan, isFalse);
        expect(permissions.canExportChallans, isFalse);
      }
    });

    test('a user with no role has no challan access at all', () {
      const permissions = OrgPermissions(null);

      expect(permissions.canViewChallans, isFalse);
      expect(permissions.canAddChallan, isFalse);
    });

    test('existing expense permissions are unchanged', () {
      const customer = OrgPermissions(OrgMemberRole.customer);
      const owner = OrgPermissions(OrgMemberRole.owner);

      expect(customer.canAddExpense, isTrue);
      expect(customer.canDeleteExpense, isFalse);
      expect(owner.canManageProjects, isTrue);
      expect(owner.canViewAuditLogs, isTrue);
    });
  });
}
