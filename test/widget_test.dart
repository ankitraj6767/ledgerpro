import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('LedgerPro app starts with branded splash', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: LedgerProApp()));

    expect(find.text('LedgerPro Mobile'), findsOneWidget);
    expect(
      find.text('Secure mobile ledger for internal business books.'),
      findsOneWidget,
    );
  });
}
