import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/core/richtext/rich_text_view.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child))),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders headings with a base style that has no font size', (
    tester,
  ) async {
    // Regression: headings used base.fontSize! which crashed when the base
    // style carried no explicit font size.
    await pump(
      tester,
      const RichTextView(
        '# H1\n## H2\n### H3\nbody',
        baseStyle: TextStyle(color: Colors.black), // no fontSize on purpose
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders links and survives rebuilds (recognizer lifecycle)', (
    tester,
  ) async {
    await pump(tester, const RichTextView('see [here](https://example.com)'));
    expect(tester.takeException(), isNull);

    // Rebuild with different content to exercise recognizer disposal.
    await pump(tester, const RichTextView('now [there](https://example.org)'));
    expect(tester.takeException(), isNull);

    // Rebuild again and pump a frame so the post-frame disposal runs.
    await pump(tester, const RichTextView('plain text, no link'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders delta and legacy content without throwing', (
    tester,
  ) async {
    await pump(
      tester,
      const RichTextView(
        '[{"insert":"a"},{"insert":"\\n","attributes":{"block":"ol"}}]',
      ),
    );
    expect(tester.takeException(), isNull);

    await pump(tester, const RichTextView('legacy **bold** note'));
    expect(tester.takeException(), isNull);
  });
}
