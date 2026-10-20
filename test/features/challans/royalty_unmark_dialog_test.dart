import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/app/theme/infra_theme.dart';
import 'package:ledgerpro_mobile/features/challans/domain/challan_models.dart';
import 'package:ledgerpro_mobile/features/challans/presentation/widgets/royalty_unmark_dialog.dart';

const _challan = EPassChallan(
  id: 'challan-1',
  organizationId: 'org-1',
  projectId: 'project-1',
  financialYear: '2026-2027',
  challanNumber: 'F102600518/43',
  normalizedChallanNumber: 'F10260051843',
  portalMineralName: 'SAND',
  vehicleNumber: 'CG12BQ7496',
  normalizedVehicleNumber: 'CG12BQ7496',
  royaltyPaid: true,
);

Future<Completer<bool>> _open(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  double textScale = 1,
  EPassChallan challan = _challan,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  final result = Completer<bool>();
  await tester.pumpWidget(
    MaterialApp(
      theme: InfraTheme.light(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () async {
                result.complete(
                  await RoyaltyUnmarkDialog.confirm(context, challan: challan),
                );
              },
              child: const Text('Review payment'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Review payment'));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  testWidgets(
    'identifies the challan and explains the pending status and audit',
    (tester) async {
      final result = await _open(tester);
      expect(find.text(_challan.challanNumber), findsOneWidget);
      expect(find.text('Royalty pending'), findsOneWidget);
      expect(
        find.text('The change will be recorded in the audit trail.'),
        findsOneWidget,
      );
      expect(result.isCompleted, isFalse);
      await tester.tap(find.text('Keep marked paid'));
      await tester.pumpAndSettle();
      expect(await result.future, isFalse);
      expect(_challan.royaltyPaid, isTrue);
    },
  );

  testWidgets('only explicit reversal returns a confirmation', (tester) async {
    final result = await _open(tester);
    await tester.tap(find.text('Unmark as unpaid'));
    await tester.pumpAndSettle();
    expect(await result.future, isTrue);
  });

  testWidgets('tapping outside leaves the payment marked paid', (tester) async {
    final result = await _open(tester);
    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();
    expect(await result.future, isFalse);
  });

  testWidgets('system back leaves the payment marked paid', (tester) async {
    final result = await _open(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(await result.future, isFalse);
  });

  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(1280, 800),
  ]) {
    testWidgets('large text at $size keeps both decisions visible', (
      tester,
    ) async {
      final result = await _open(
        tester,
        size: size,
        textScale: 2,
        challan: _challan.copyWith(
          challanNumber: '241381260603123853167-2026-LONG-REFERENCE',
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Keep marked paid').hitTestable(), findsOneWidget);
      expect(find.text('Unmark as unpaid').hitTestable(), findsOneWidget);
      await tester.ensureVisible(find.text('Royalty pending'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Keep marked paid'));
      await tester.pumpAndSettle();
      expect(await result.future, isFalse);
    });
  }
}
