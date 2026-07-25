import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/features/challans/data/challan_repository.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_exceptions.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_status.dart';
import 'package:ledgerpro_mobile/features/challans/domain/material_type.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('row mapping', () {
    final row = <String, dynamic>{
      'id': 'challan-1',
      'organization_id': 'org-1',
      'project_id': 'project-1',
      'source_portal': 'bihar_khanan_soft',
      'portal_url': 'https://khanansoft.bihar.gov.in/portal/ePass/x.aspx',
      'financial_year': '2026-2027',
      'challan_number': 'BR-2026-001234',
      'normalized_challan_number': 'BR2026001234',
      'uid_number': 'UID-99',
      'challan_date': '2026-05-12T09:00:00Z',
      'valid_until': '2026-05-13T09:00:00Z',
      'selected_material_type': 'sand',
      'portal_mineral_name': 'Sand (Balu)',
      // Postgres numeric arrives as a string to preserve precision.
      'quantity': '12.500',
      'quantity_unit': 'MT',
      'vehicle_type': 'Truck',
      'vehicle_number': 'BR 01 GH 4567',
      'normalized_vehicle_number': 'BR01GH4567',
      'consignor_name': 'Bihar Minerals',
      'consignee_name': 'Navdream Infra',
      'source_location': 'Patna',
      'destination': 'Gaya',
      'generated_from': 'Mine Owner',
      'royalty_amount_paise': 125050,
      'portal_payload': {
        'fields': {'challanNumber': 'BR-2026-001234'},
      },
      'portal_response_hash': 'abc123',
      'verification_status': 'portal_captured',
      'verification_method': 'webview_human_verification',
      'captured_at': '2026-05-12T10:00:00Z',
      'verified_at': '2026-05-12T10:00:00Z',
      'created_by': 'user-1',
      'created_at': '2026-05-12T10:00:01Z',
      'updated_at': '2026-05-12T10:00:01Z',
      'deleted_at': null,
      'infra_projects': {'name': 'Highway Package 3'},
    };

    test('maps every snake_case column onto the Dart model', () {
      final challan = ChallanRepository.challanFromRow(row);

      expect(challan.id, 'challan-1');
      expect(challan.organizationId, 'org-1');
      expect(challan.projectId, 'project-1');
      expect(challan.financialYear, '2026-2027');
      expect(challan.challanNumber, 'BR-2026-001234');
      expect(challan.normalizedChallanNumber, 'BR2026001234');
      expect(challan.uidNumber, 'UID-99');
      expect(challan.challanDate, DateTime.utc(2026, 5, 12, 9));
      expect(challan.selectedMaterialType, ChallanMaterialType.sand);
      expect(challan.portalMineralName, 'Sand (Balu)');
      expect(challan.quantity, 12.5);
      expect(challan.quantityUnit, 'MT');
      expect(challan.vehicleNumber, 'BR 01 GH 4567');
      expect(challan.normalizedVehicleNumber, 'BR01GH4567');
      expect(challan.royaltyAmountPaise, 125050);
      expect(challan.portalResponseHash, 'abc123');
      expect(
        challan.verificationStatus,
        ChallanVerificationStatus.portalCaptured,
      );
      expect(
        challan.verificationMethod,
        ChallanVerificationMethod.webviewHumanVerification,
      );
      expect(challan.createdBy, 'user-1');
      expect(challan.deletedAt, isNull);
      // Joined project name is exposed for display.
      expect(challan.projectName, 'Highway Package 3');
      expect(challan.isPortalCaptured, isTrue);
    });

    test('numeric strings keep their decimal value', () {
      expect(
        ChallanRepository.challanFromRow({
          ...row,
          'quantity': '0.125',
        }).quantity,
        0.125,
      );
      expect(
        ChallanRepository.challanFromRow({...row, 'quantity': 42}).quantity,
        42,
      );
    });

    test('tolerates a nested project join returned as a list', () {
      final challan = ChallanRepository.challanFromRow({
        ...row,
        'infra_projects': [
          {'name': 'Bridge Works'},
        ],
      });

      expect(challan.projectName, 'Bridge Works');
    });

    test('missing optional columns become null, not empty strings', () {
      final sparse = <String, dynamic>{
        'id': 'challan-2',
        'organization_id': 'org-1',
        'project_id': 'project-1',
        'financial_year': '2026-2027',
        'challan_number': 'BR2',
        'normalized_challan_number': 'BR2',
        'portal_mineral_name': 'Stone',
        'quantity': '1',
        'vehicle_number': 'BR02',
        'normalized_vehicle_number': 'BR02',
        'verification_status': 'manual_unverified',
        'verification_method': 'manual_entry',
      };
      final challan = ChallanRepository.challanFromRow(sparse);

      expect(challan.uidNumber, isNull);
      expect(challan.challanDate, isNull);
      expect(challan.royaltyAmountPaise, isNull);
      expect(challan.selectedMaterialType, isNull);
      expect(challan.projectName, isNull);
      expect(challan.portalPayload, isEmpty);
      expect(challan.quantityUnit, 'MT');
    });
  });

  group('Postgrest error mapping', () {
    ChallanException map(String message, {String? code}) =>
        ChallanRepository.mapPostgrestError(
          PostgrestException(message: message, code: code),
        );

    test('a unique violation becomes an explicit duplicate error', () {
      expect(
        map(
          'duplicate key value violates unique constraint',
          code: '23505',
        ).kind,
        ChallanErrorKind.duplicateChallan,
      );
      expect(
        map('DUPLICATE_CHALLAN: this challan is already saved').kind,
        ChallanErrorKind.duplicateChallan,
      );
      expect(
        map(
          'duplicate key value violates unique constraint '
          '"epass_challans_unique_challan_idx"',
        ).kind,
        ChallanErrorKind.duplicateChallan,
      );
    });

    test('the duplicate message is the user-facing wording', () {
      expect(map('DUPLICATE_CHALLAN').message, 'This challan is already saved');
    });

    test('permission failures map to permission denied', () {
      expect(
        map('Not permitted to add challans').kind,
        ChallanErrorKind.permissionDenied,
      );
      expect(
        map('new row violates row-level security policy').kind,
        ChallanErrorKind.permissionDenied,
      );
      expect(
        map('permission denied for table', code: '42501').kind,
        ChallanErrorKind.permissionDenied,
      );
    });

    test('a deleted project maps to projectMissing', () {
      expect(
        map('Project no longer exists').kind,
        ChallanErrorKind.projectMissing,
      );
    });

    test('auth failures map to sessionExpired', () {
      expect(
        map('Sign in again to save a challan').kind,
        ChallanErrorKind.sessionExpired,
      );
      expect(
        map('JWT expired', code: 'PGRST301').kind,
        ChallanErrorKind.sessionExpired,
      );
    });

    test('timeouts map to supabaseTimeout', () {
      expect(
        map('canceling statement due to statement timeout').kind,
        ChallanErrorKind.supabaseTimeout,
      );
    });

    test('an unrecognized error never leaks raw Postgres text', () {
      final mapped = map(
        'ERROR: column "x" does not exist at character 42 HINT: internal',
      );

      expect(mapped.kind, ChallanErrorKind.unknown);
      expect(mapped.message, isNot(contains('column')));
      expect(mapped.message, isNot(contains('character 42')));
      expect(mapped.message, ChallanException.unknown.message);
    });

    test('official API writes are refused until that integration exists', () {
      expect(
        map('official_api verification is not available yet').kind,
        ChallanErrorKind.permissionDenied,
      );
    });
  });

  group('error surface', () {
    test('every error message is user-safe and actionable', () {
      const errors = <ChallanException>[
        ChallanException.noInternet,
        ChallanException.portalUnavailable,
        ChallanException.portalTimeout,
        ChallanException.pageNotLoaded,
        ChallanException.captchaNotCompleted,
        ChallanException.challanNotFound,
        ChallanException.portalLayoutChanged,
        ChallanException.platformUnsupported,
        ChallanException.sessionExpired,
        ChallanException.permissionDenied,
        ChallanException.projectMissing,
        ChallanException.supabaseTimeout,
      ];

      for (final error in errors) {
        expect(error.message, isNotEmpty);
        expect(error.recoveryHint, isNotNull);
        // No stack traces or exception plumbing in user-facing text.
        expect(error.message, isNot(contains('Exception')));
        expect(error.message, isNot(contains('#0')));
      }
    });

    test('every error kind is representable', () {
      expect(ChallanErrorKind.values.length, greaterThanOrEqualTo(16));
    });
  });
}
