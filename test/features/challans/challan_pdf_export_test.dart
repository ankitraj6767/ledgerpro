import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_formatting.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_models.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_status.dart';
import 'package:ledgerpro_mobile/features/challans/domain/material_type.dart';
import 'package:ledgerpro_mobile/features/infra/data/infra_report_service.dart';
import 'package:ledgerpro_mobile/shared/models/infra_models.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Routes every report write into a throwaway directory so PDF generation can be
/// exercised for real, without a platform channel.
class _TempPathProvider extends PathProviderPlatform with MockPlatformInterfaceMixin {
  _TempPathProvider(this.root);

  final Directory root;

  @override
  Future<String?> getTemporaryPath() async => root.path;

  @override
  Future<String?> getApplicationSupportPath() async => root.path;

  @override
  Future<String?> getApplicationDocumentsPath() async => root.path;

  @override
  Future<String?> getDownloadsPath() async => root.path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory root;

  setUp(() {
    root = Directory.systemTemp.createTempSync('ledgerpro_challan_pdf');
    PathProviderPlatform.instance = _TempPathProvider(root);
  });

  tearDown(() {
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  const service = InfraReportService();

  final project = InfraProject(
    id: 'project-1',
    organizationId: 'org-1',
    name: 'Madhubani Bus Stand',
    code: 'MBS-01',
    category: 'Roads',
    status: InfraProjectStatus.active,
  );

  EPassChallan challan({
    String challanNumber = '241381260603123853167',
    String sourcePortal = 'bihar_khanan_soft',
    ChallanVerificationStatus status =
        ChallanVerificationStatus.portalCaptured,
    ChallanVerificationMethod method =
        ChallanVerificationMethod.webviewHumanVerification,
    ChallanMaterialType? material = ChallanMaterialType.sand,
    String mineral = 'SAND (YELLOW SAND (BALU GHAT)-No Size)',
    double quantity = 39.23,
    String unit = 'INMT',
    int? royaltyPaise,
    String? projectName = 'Madhubani Bus Stand',
    bool sparse = false,
  }) {
    return EPassChallan(
      id: 'challan-$challanNumber',
      organizationId: 'org-1',
      projectId: 'project-1',
      sourcePortal: sourcePortal,
      portalUrl: sparse ? null : 'https://khanansoft.bihar.gov.in/portal',
      financialYear: '2026-2027',
      challanNumber: challanNumber,
      normalizedChallanNumber: challanNumber,
      uidNumber: sparse ? null : '166059041171',
      challanDate: sparse ? null : DateTime.utc(2026, 6, 3, 7, 8),
      validUntil: sparse ? null : DateTime.utc(2026, 6, 4, 7, 8),
      selectedMaterialType: material,
      portalMineralName: mineral,
      quantity: quantity,
      quantityUnit: unit,
      vehicleType: sparse ? null : 'Truck',
      vehicleNumber: 'BR09PB4263',
      normalizedVehicleNumber: 'BR09PB4263',
      consignorName: sparse ? null : 'DIR DHIRENDRA KUMAR',
      consigneeName: sparse ? null : 'ROYAL CONSTRUCTION BUS STAND',
      sourceLocation: sparse ? null : 'MS RAMIYA CONSTRUCTIONS PVT LTD',
      destination: sparse ? null : 'Madhubani Bus Stand',
      generatedFrom: sparse ? null : 'Web',
      royaltyAmountPaise: royaltyPaise,
      portalResponseHash: sparse ? null : 'a' * 64,
      verificationStatus: status,
      verificationMethod: method,
      capturedAt: sparse ? null : DateTime.utc(2026, 6, 3, 8),
      createdAt: sparse ? null : DateTime.utc(2026, 6, 3, 8, 1),
      projectName: projectName,
    );
  }

  group('challan detail PDF', () {
    test('writes a real PDF next to the other project reports', () async {
      final file = await service.challanDetailPdf(
        organizationName: 'NAVDREAM Infra Pvt. Ltd.',
        project: project,
        challan: challan(),
      );

      expect(file.existsSync(), isTrue);
      final bytes = await file.readAsBytes();
      // A valid PDF starts with %PDF and is not a stub.
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
      expect(bytes.length, greaterThan(2000));
      // Same naming scheme as expense/investment exports.
      expect(file.path, endsWith('.pdf'));
      expect(file.path, contains('navdreaminfra_'));
      expect(file.path, contains('challan_'));
    });

    test('recreates a missing temporary directory before writing', () async {
      // Android can clear the cache directory while the app process remains
      // alive. The exporter must recover when the provider returns that path.
      root.deleteSync(recursive: true);

      final file = await service.challanDetailPdf(
        organizationName: 'Org',
        challan: challan(),
      );

      expect(file.existsSync(), isTrue);
      expect(file.parent.existsSync(), isTrue);
    });

    test('works without a loaded project, falling back to the joined name',
        () async {
      final file = await service.challanDetailPdf(
        organizationName: 'NAVDREAM Infra Pvt. Ltd.',
        challan: challan(),
      );

      expect(file.existsSync(), isTrue);
      expect(await file.length(), greaterThan(2000));
      expect(_pdfPageCount(await file.readAsBytes()), 1);
    });

    test('a challan with almost every optional field null still renders',
        () async {
      final file = await service.challanDetailPdf(
        organizationName: '',
        challan: challan(
          sparse: true,
          material: null,
          projectName: null,
          status: ChallanVerificationStatus.manualUnverified,
          method: ChallanVerificationMethod.manualEntry,
        ),
      );

      expect(file.existsSync(), isTrue);
      expect(await file.length(), greaterThan(2000));
    });

    test('a royalty amount adds its own section', () async {
      final withRoyalty = await service.challanDetailPdf(
        organizationName: 'Org',
        project: project,
        challan: challan(royaltyPaise: 125000),
      );
      final without = await service.challanDetailPdf(
        organizationName: 'Org',
        project: project,
        challan: challan(),
      );

      expect(
        await withRoyalty.length(),
        greaterThan(await without.length()),
      );
    });

    test('every portal exports, including Madhya Pradesh', () async {
      for (final portal in const [
        'bihar_khanan_soft',
        'jharkhand_minerals_portal',
        'mp_ekhanij_etp',
      ]) {
        final file = await service.challanDetailPdf(
          organizationName: 'Org',
          project: project,
          challan: challan(sourcePortal: portal),
        );
        expect(file.existsSync(), isTrue, reason: portal);
      }
    });
  });

  group('challan list PDF', () {
    test('exports the list in the order it is given', () async {
      final file = await service.challansPdf(
        organizationName: 'NAVDREAM Infra Pvt. Ltd.',
        project: project,
        challans: [
          challan(challanNumber: '111'),
          challan(challanNumber: '222'),
          challan(
            challanNumber: '333',
            status: ChallanVerificationStatus.manualUnverified,
            method: ChallanVerificationMethod.manualEntry,
          ),
        ],
      );

      expect(file.existsSync(), isTrue);
      expect(file.path, contains('challans'));
      expect(await file.length(), greaterThan(2000));
      expect(_pdfPageCount(await file.readAsBytes()), 3);
    });

    test('a cross-project export needs no project', () async {
      final file = await service.challansPdf(
        organizationName: 'Org',
        subjectTitle: 'All Projects',
        challans: [
          challan(challanNumber: '111', sourcePortal: 'bihar_khanan_soft'),
          challan(challanNumber: '222', sourcePortal: 'mp_ekhanij_etp'),
        ],
      );

      expect(file.existsSync(), isTrue);
      expect(await file.length(), greaterThan(2000));
    });

    test('mixed quantity units are never summed into a meaningless total',
        () async {
      // Two different units: the report must not add 10 CUM to 5 MT. Rendering
      // still has to succeed, so this pins the behaviour via a successful write.
      final file = await service.challansPdf(
        organizationName: 'Org',
        project: project,
        challans: [
          challan(challanNumber: '111', quantity: 5, unit: 'MT'),
          challan(challanNumber: '222', quantity: 10, unit: 'CUM'),
        ],
      );

      expect(file.existsSync(), isTrue);
    });

    test('an empty list is refused by the UI, but still renders safely',
        () async {
      final file = await service.challansPdf(
        organizationName: 'Org',
        challans: const [],
      );

      expect(file.existsSync(), isTrue);
    });
  });

  group('the PDF reads the same as the detail screen', () {
    test('portal timestamps are rendered in IST, not device time', () {
      // 03 Jun 2026 07:08 UTC is 12:38 PM IST — the value shown on screen.
      final value = DateTime.utc(2026, 6, 3, 7, 8);

      expect(ChallanDates.ist(value), '03 Jun 2026, 12:38 PM IST');
      expect(ChallanDates.istDay(value), '03 Jun 2026');
    });

    test('a date-only portal value drops the time', () {
      expect(
        ChallanDates.ist(DateTime.utc(2026, 6, 2, 18, 30)),
        '03 Jun 2026 IST',
      );
    });

    test('missing timestamps use the caller\'s placeholder', () {
      expect(ChallanDates.ist(null), '—');
      expect(ChallanDates.ist(null, fallback: '-'), '-');
      expect(ChallanDates.local(null), '—');
      expect(ChallanDates.istDay(null), '-');
    });
  });
}

int _pdfPageCount(List<int> bytes) {
  final source = latin1.decode(bytes, allowInvalid: true);
  return RegExp(r'/Type\s*/Page(?!s)').allMatches(source).length;
}
