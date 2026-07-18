import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/core/richtext/rich_text_editor.dart';

void main() {
  Widget host(TextEditingController controller) {
    return MaterialApp(
      localizationsDelegates: const [
        FleatherLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        body: SingleChildScrollView(
          child: RichTextEditorField(controller: controller, label: 'Notes'),
        ),
      ),
    );
  }

  testWidgets('builds cleanly for empty, legacy-plain and delta content', (
    tester,
  ) async {
    final cases = <String>[
      '',
      'legacy plain note',
      '[{"insert":"hi\\n"}]',
    ];
    for (final initial in cases) {
      final controller = TextEditingController(text: initial);
      await tester.pumpWidget(host(controller));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'failed for "$initial"');
      controller.dispose();
    }
  });

  testWidgets('renders the formatting toolbar', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(host(controller));
    await tester.pumpAndSettle();
    // Fleather's basic toolbar exposes bold as an icon button.
    expect(find.byIcon(Icons.format_bold), findsOneWidget);
    controller.dispose();
  });
}
