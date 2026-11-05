import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:anotara/screens/settings/settings_screens.dart';
import 'package:anotara/components/organisms/delete_account_modal.dart';

void main() {
  setUp(() { GoogleFonts.config.allowRuntimeFetching = false; });
  testWidgets('FAQ switches the expanded answer', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HelpSupportScreen()));
    expect(find.textContaining('Go to Settings'), findsOneWidget);
    await tester.tap(find.text('Why is my payment still pending?'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Go to Settings'), findsNothing);
    expect(find.textContaining('Payment confirmation may take time.'), findsOneWidget);
  });
  testWidgets('delete requires a password before invoking callback', (tester) async {
    var calls = 0;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: DeleteAccountModal(onDelete: (_) async { calls++; }))));
    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your password to continue.'), findsOneWidget);
    expect(calls, 0);
  });
}
