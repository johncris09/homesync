import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/app_services.dart';
import 'package:homesync/core/auth/secure_store.dart';
import 'package:homesync/core/vault/vault_crypto.dart';
import 'package:homesync/features/vault/vault_repository.dart';

import '../app_test.dart' as app;
import '../support/test_db.dart';
import 'budget_screen_test.dart' show helper, signedInAs, tapText;

Future<AppServices> open(MemorySecureStore store) async {
  final s = await AppServices.open(
    secureStore: store,
    database: memoryDb(),
    vaultCrypto: VaultCrypto(iterations: 1000),
  );
  await s.writer.insert('members', {'name': 'Mama', 'role': 'owner'}, id: app.me.memberId);
  return s;
}

/// Lets real async work (crypto, database) and the fake clock take turns.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pump(const Duration(milliseconds: 50));
  }
  await tester.pumpAndSettle();
}

VaultRepository repoOf(AppServices s) =>
    VaultRepository(db: s.db, writer: s.writer, session: s.vault, crypto: s.vaultCrypto, files: s.vaultFiles);

void main() {
  testWidgets('owner: set-up needs a connection and a long enough passphrase', (tester) async {
    final store = MemorySecureStore();
    app.signedIn(store);
    final s = (await tester.runAsync(() => open(store)))!;
    await app.pumpApp(tester, s);
    expect(find.text('Not set up yet'), findsOneWidget);

    await tapText(tester, 'Document vault');
    expect(find.text('Set up the vault'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('vault-pass-1')), 'short');
    await tester.enterText(find.byKey(const Key('vault-pass-2')), 'short');
    await tapText(tester, 'Set up');
    expect(find.textContaining('Use at least 10 characters'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('vault-pass-1')), 'bahay kubo sa bukid');
    await tester.enterText(find.byKey(const Key('vault-pass-2')), 'bahay kubo sa parang');
    await tapText(tester, 'Set up');
    expect(find.text("The passphrases don't match"), findsOneWidget);

    // No hub in tests: set-up refuses to make a key offline.
    await tester.enterText(find.byKey(const Key('vault-pass-2')), 'bahay kubo sa bukid');
    await tester.tap(find.text('Set up'));
    await settle(tester);
    expect(find.textContaining('Connect to the internet'), findsOneWidget);
    expect(await tester.runAsync(() => repoOf(s).keyRow()), isNull);
    await app.finish(tester, s);
  });

  testWidgets('adult: unlock with the passphrase, add a document, see it masked, lock again', (tester) async {
    final store = MemorySecureStore();
    app.signedIn(store);
    final s = (await tester.runAsync(() async {
      final s = await open(store);
      await repoOf(s).setUp('bahay kubo sa bukid');
      s.vault.lock();
      return s;
    }))!;
    await app.pumpApp(tester, s);
    expect(find.text('Nothing kept yet'), findsOneWidget);

    await tapText(tester, 'Document vault');
    expect(find.text('No documents'), findsOneWidget);
    expect(find.text('Locked. Encrypted on this device.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('vault-unlock-pass')), 'wrong passphrase');
    await tester.tap(find.text('Unlock'));
    await settle(tester);
    expect(find.text("That passphrase didn't open the vault"), findsOneWidget);

    await tester.enterText(find.byKey(const Key('vault-unlock-pass')), 'bahay kubo sa bukid');
    await tester.tap(find.text('Unlock'));
    await settle(tester);
    expect(find.textContaining('Add IDs, birth certificates'), findsOneWidget);

    await tapText(tester, 'Add document');
    await tapText(tester, 'Save');
    expect(find.text('Give the document a name'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('vault-title')), 'Passport');
    await tester.enterText(find.byKey(const Key('vault-number-field')), 'P1234542B');
    await tester.ensureVisible(find.byKey(const Key('vault-save')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('vault-save')));
    await settle(tester);

    // The document opens: number masked until shown.
    expect(find.text('Passport'), findsWidgets);
    expect(find.text('Number'), findsOneWidget);
    expect(find.text('P•••••42B'), findsOneWidget);
    await tester.tap(find.byTooltip('Show number'));
    await tester.pumpAndSettle();
    expect(find.text('P1234542B'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await settle(tester);
    expect(find.text('IDs'), findsOneWidget);
    expect(find.text('1 document'), findsOneWidget);
    expect(find.text('P•••••42B'), findsOneWidget);

    // Stored sealed.
    final raw = await tester.runAsync(() => s.db.select(s.db.vaultItems).getSingle());
    expect(raw!.sealed, isNot(contains('P1234542B')));

    await tester.tap(find.byTooltip('Lock'));
    await tester.pumpAndSettle();
    expect(find.text('Locked. Encrypted on this device.'), findsOneWidget);
    expect(find.text('Passport'), findsNothing);
    await app.finish(tester, s);
  });

  testWidgets('owner: a new recovery code is shown until they confirm keeping it', (tester) async {
    final store = MemorySecureStore();
    app.signedIn(store);
    final s = (await tester.runAsync(() async {
      final s = await open(store);
      await repoOf(s).setUp('bahay kubo sa bukid');
      return s;
    }))!;
    await app.pumpApp(tester, s);
    await tapText(tester, 'Document vault');

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New recovery code'));
    await settle(tester);
    expect(find.text('Your recovery code'), findsOneWidget);
    final code = tester.widget<SelectableText>(find.byKey(const Key('vault-recovery-code'))).data!;
    expect(RecoveryCode.tryParse(code.replaceAll('\n', '-')), isNotNull);

    final finish = find.widgetWithText(FilledButton, 'Finish');
    expect(tester.widget<FilledButton>(finish).onPressed, isNull);
    await tester.tap(find.byKey(const Key('vault-recovery-saved')));
    await tester.pumpAndSettle();
    await tester.tap(finish);
    await tester.pumpAndSettle();
    expect(find.text('Your recovery code'), findsNothing);

    // The new code opens the vault.
    s.vault.lock();
    final ok = await tester.runAsync(() => repoOf(s).unlockWithRecovery(code.replaceAll('\n', '-')));
    expect(ok, isTrue);
    await app.finish(tester, s);
  });

  testWidgets('helpers do not see the vault', (tester) async {
    final store = MemorySecureStore();
    signedInAs(store, helper);
    final s = (await tester.runAsync(() => open(store)))!;
    await app.pumpApp(tester, s);
    expect(find.text('Record an expense'), findsOneWidget);
    expect(find.text('Document vault'), findsNothing);
    await app.finish(tester, s);
  });
}
