import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/app_services.dart';
import 'package:homesync/core/auth/auth_service.dart';
import 'package:homesync/core/auth/pin_hash.dart';
import 'package:homesync/core/auth/secure_store.dart';

import '../app_test.dart' as app;
import '../support/test_db.dart';

const helperId = '01900000-0000-7000-8000-0000000000bb';

Future<AppServices> seeded(MemorySecureStore store) async {
  final s = await app.services(store);
  await s.writer.insert('members', {'name': 'Mama', 'role': 'owner'}, id: app.me.memberId);
  await s.writer.insert('members', {'name': 'Ate Joy', 'role': 'helper'}, id: helperId);
  return s;
}

Future<void> openMembers(WidgetTester tester) async {
  await tester.tap(find.text('Household members'));
  await tester.pumpAndSettle();
}

Future<void> enterPin(WidgetTester tester, String pin) async {
  for (final d in pin.split('')) {
    await tester.tap(find.text(d).last);
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

Future<Map<String, Object?>> row(WidgetTester tester, AppServices s, String id) async =>
    (await tester.runAsync(() => rawRow(s.db, 'members', id)))!;

void main() {
  testWidgets('owner adds a member with a role and colour', (tester) async {
    final store = MemorySecureStore();
    app.signedIn(store);
    final s = (await tester.runAsync(() => seeded(store)))!;
    await app.pumpApp(tester, s);
    await openMembers(tester);
    expect(find.text('2 people'), findsOneWidget);
    expect(find.text('Helper · no tablet PIN'), findsOneWidget);

    await tester.tap(find.text('Add person'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Enter a name.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('member-name')), '  Lolo Ben ');
    await tester.tap(find.text('Child'));
    await tester.tap(find.bySemanticsLabel('#2B5C8A'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('3 people'), findsOneWidget);
    final added = (await tester.runAsync(
      () => s.db.customSelect("SELECT * FROM members WHERE name = 'Lolo Ben'").getSingle(),
    ))!.data;
    expect(added['role'], 'child');
    expect(added['color'], '#2B5C8A');
    final ops = (await tester.runAsync(() => s.db.select(s.db.outbox).get()))!;
    expect(ops.where((o) => o.entityId == added['id'] && o.op == 'insert'), hasLength(1));
    await app.finish(tester, s);
  });

  testWidgets('owner sets a PIN the tablet can verify, then removes it', (tester) async {
    final store = MemorySecureStore();
    app.signedIn(store);
    final s = (await tester.runAsync(() => seeded(store)))!;
    await app.pumpApp(tester, s);
    await openMembers(tester);

    await tester.tap(find.text('Ate Joy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Set tablet PIN'));
    await tester.pumpAndSettle();
    expect(find.text('PIN for Ate Joy'), findsOneWidget);
    await enterPin(tester, '1357');
    await enterPin(tester, '1358');
    expect(find.text("The PINs don't match."), findsOneWidget);
    await enterPin(tester, '1357');

    final hash = (await row(tester, s, helperId))['pin_hash'] as String?;
    expect(hash, startsWith(r'$2y$10$'));
    expect(await tester.runAsync(() => verifyPin('1357', hash)), isTrue);
    expect(find.text('Helper · tablet PIN set'), findsOneWidget);

    await tester.tap(find.text('Ate Joy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove tablet PIN'));
    await tester.pumpAndSettle();
    expect((await row(tester, s, helperId))['pin_hash'], isNull);
    await app.finish(tester, s);
  });

  testWidgets('owner removes a member but not themself', (tester) async {
    final store = MemorySecureStore();
    app.signedIn(store);
    final s = (await tester.runAsync(() => seeded(store)))!;
    await app.pumpApp(tester, s);
    await openMembers(tester);

    await tester.tap(find.text('Mama'));
    await tester.pumpAndSettle();
    expect(find.text('Remove'), findsNothing);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ate Joy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Remove'));
    await tester.pumpAndSettle();

    expect((await row(tester, s, helperId))['deleted_at'], isNotNull);
    expect(find.text('Ate Joy'), findsNothing);
    expect(find.text('1 person'), findsOneWidget);
    await app.finish(tester, s);
  });

  testWidgets('non-owners do not get the members screen', (tester) async {
    final store = MemorySecureStore();
    const adult = Profile(memberId: helperId, name: 'Papa', role: 'adult', deviceId: 'b0000000-0000-7000-8000-00000000000b');
    store.values['session'] = jsonEncode(
      const Session(householdId: householdId, householdName: 'Manabo', isShared: false, main: adult, active: adult).toJson(),
    );
    final s = (await tester.runAsync(() => app.services(store)))!;
    await app.pumpApp(tester, s);
    expect(find.text('Household members'), findsNothing);
    await app.finish(tester, s);
  });
}
