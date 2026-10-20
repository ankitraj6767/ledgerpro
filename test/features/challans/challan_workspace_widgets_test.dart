import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/app/theme/infra_theme.dart';
import 'package:ledgerpro_mobile/features/challans/application/challan_flow_state.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_models.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_status.dart';
import 'package:ledgerpro_mobile/features/challans/domain/material_type.dart';
import 'package:ledgerpro_mobile/features/challans/presentation/widgets/challan_card.dart';
import 'package:ledgerpro_mobile/features/challans/presentation/widgets/challan_step_indicator.dart';
import 'package:ledgerpro_mobile/features/challans/presentation/widgets/challan_workspace_theme.dart';

const _challan = EPassChallan(
  id: 'challan-1',
  organizationId: 'org-1',
  projectId: 'project-1',
  financialYear: '2026-2027',
  challanNumber: 'F102600518/43',
  normalizedChallanNumber: 'F10260051843',
  portalMineralName: 'Stone Chips',
  vehicleNumber: 'CG12BQ7496',
  normalizedVehicleNumber: 'CG12BQ7496',
  quantity: 945,
  quantityUnit: 'CFT',
  projectName: 'Madhubani Bus Stand',
  verificationStatus: ChallanVerificationStatus.portalCaptured,
  verificationMethod: ChallanVerificationMethod.webviewHumanVerification,
);

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  double width = 390,
  double textScale = 1,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 900);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: InfraTheme.light(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: ChallanWorkspaceTheme(
        child: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'PDF selection, royalty updates, and detail navigation stay separate',
    (tester) async {
      var selected = false;
      var royaltyUpdates = 0;
      var detailOpens = 0;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => ChallanCard(
            challan: _challan,
            selected: selected,
            onSelectionChanged: (value) =>
                setState(() => selected = value ?? false),
            onRoyaltyPaidChanged: (paid) async {
              royaltyUpdates++;
            },
            onTap: () => detailOpens++,
          ),
        ),
      );
      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();
      expect(selected, isTrue);
      expect(royaltyUpdates, 0);
      expect(detailOpens, 0);
      await tester.tap(find.byType(Checkbox).last);
      await tester.pumpAndSettle();
      expect(royaltyUpdates, 1);
      expect(find.text('Royalty paid'), findsOneWidget);
      expect(detailOpens, 0);
      await tester.tap(find.text(_challan.challanNumber));
      expect(detailOpens, 1);
    },
  );

  testWidgets('a failed royalty update restores the previous payment status', (
    tester,
  ) async {
    final pending = Completer<void>();
    await _pump(
      tester,
      ChallanCard(
        challan: _challan,
        onRoyaltyPaidChanged: (_) => pending.future,
      ),
    );
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Royalty paid'), findsOneWidget);
    pending.completeError(StateError('Update failed'));
    await tester.pumpAndSettle();
    expect(find.text('Royalty pending'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
  });

  for (final width in [320.0, 900.0]) {
    testWidgets(
      'progress navigation at width $width only opens completed steps',
      (tester) async {
        final visited = <ChallanFlowStep>[];
        await _pump(
          tester,
          ChallanStepIndicator(
            current: ChallanFlowStep.preview,
            onStepTapped: visited.add,
          ),
          width: width,
        );
        await tester.tap(find.byTooltip(ChallanFlowStep.selection.title));
        await tester.tap(find.byTooltip(ChallanFlowStep.portal.title));
        await tester.tap(find.byTooltip(ChallanFlowStep.preview.title));
        await tester.tap(find.byTooltip(ChallanFlowStep.save.title));
        expect(visited, [ChallanFlowStep.selection, ChallanFlowStep.portal]);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final status in ChallanVerificationStatus.values) {
    testWidgets(
      'large text and long details fit a narrow card with ${status.name}',
      (tester) async {
        await _pump(
          tester,
          ChallanCard(
            challan: _challan.copyWith(
              challanNumber: '241381260603123853167-LONG-REFERENCE',
              projectName:
                  'Highway construction and infrastructure improvement project',
              portalMineralName: 'STONE Stone Chips and Aggregate',
              selectedMaterialType: ChallanMaterialType.sand,
              verificationStatus: status,
            ),
            onSelectionChanged: (_) {},
            onRoyaltyPaidChanged: (_) async {},
          ),
          width: 320,
          textScale: 2,
        );
        await tester.ensureVisible(find.text('Royalty pending'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          find.byTooltip('Selected material differs from portal mineral'),
          findsOneWidget,
        );
        expect(find.text('Portal (human verified)'), findsOneWidget);
      },
    );
  }
}
