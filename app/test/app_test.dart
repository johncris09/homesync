import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/app/app.dart';
import 'package:homesync/app/providers.dart';
import 'package:homesync/core/app_services.dart';
import 'package:homesync/core/auth/auth_service.dart';
import 'package:homesync/core/auth/pin_hash.dart';
import 'package:homesync/core/auth/secure_store.dart';
import 'package:homesync/features/sync/conflict_inbox_screen.dart';

import 'support/test_db.dart';

const me = Profile(
  memberId: '01900000-0000-7000-8000-0000000000aa',
  name: 'Mama',
  role: 'owner',
  deviceId: 'a0000000-0000-7000-8000-00000000000a',
);

Future<AppServices> services(MemorySecureStore store) =>
    AppServices.open(secureStore: store, database: memoryDb());

/// Unmounts the app, lets Drift's stream-cleanup timers fire, then closes the
/// database outside the fake clock.
Future<void> finish(WidgetTester tester, AppServices s) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
  await tester.runAsync(s.close);
}

void signedIn(MemorySecureStore store, {bool shared = false}) {
  store.values['session'] = jsonEncode(
    Session(householdId: householdId, householdName: 'Manabo', isShared: shared, main: me, active: me).toJson(),
  );
}

Future<void> pumpApp(WidgetTester tester, AppServices s) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [servicesProvider.overrideWithValue(s)],
      child: const HomeSyncApp(attachTriggers: false),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('signed out: the sign-in screen shows', (tester) async {
    final s = await tester.runAsync(() => services(MemorySecureStore()));
    await pumpApp(tester, s!);
    expect(find.text('Sign in'), findsWidgets);
    expect(find.text('This is the shared household tablet'), findsOneWidget);
    await finish(tester, s);
  });

  testWidgets('signed in: home greets the member and shows sync state', (tester) async {
    final store = MemorySecureStore();
    signedIn(store);
    final s = await tester.runAsync(() => services(store));
    await pumpApp(tester, s!);
    expect(find.text('Hi, Mama'), findsOneWidget);
    expect(find.text('Not synced yet'), findsOneWidget);
    expect(find.text('Conflict inbox'), findsOneWidget);
    expect(find.text('Switch person'), findsNothing, reason: 'not a shared tablet');
    await finish(tester, s);
  });

  testWidgets('shared tablet: offers switching person', (tester) async {
    final store = MemorySecureStore();
    signedIn(store, shared: true);
    store.values['tablet_main_pin_hash'] = hashPin('2468');
    final s = await tester.runAsync(() => services(store));
    await pumpApp(tester, s!);
    expect(find.text('Switch person'), findsOneWidget);
    await finish(tester, s);
  });

  testWidgets('new shared tablet: the setup person chooses their tablet PIN first', (tester) async {
    final store = MemorySecureStore();
    signedIn(store, shared: true);
    final s = await tester.runAsync(() async {
      final s = await services(store);
      await s.writer.insert('members', {'name': 'Mama', 'role': 'owner'}, id: me.memberId);
      return s;
    });
    await pumpApp(tester, s!);
    expect(find.text('Your tablet PIN'), findsOneWidget);
    expect(find.text('Hi, Mama'), findsNothing);

    Future<void> enter(String pin) async {
      for (final d in pin.split('')) {
        await tester.tap(find.text(d).last);
        await tester.pump();
      }
      await tester.pumpAndSettle();
    }

    await enter('2468');
    expect(find.text('Enter the PIN again'), findsOneWidget);
    await enter('2469');
    expect(find.text("The PINs don't match."), findsOneWidget);
    await enter('2468');
    await enter('2468');
    // Wait out the bcrypt work done off the fake clock.
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();

    expect(find.text('Hi, Mama'), findsOneWidget);
    expect(store.values['tablet_main_pin_hash'], startsWith(r'$2y$10$'));
    final row = await tester.runAsync(() => rawRow(s.db, 'members', me.memberId));
    expect(row!['pin_hash'], startsWith(r'$2y$10$'), reason: "the owner's PIN also syncs");
    await finish(tester, s);
  });

  testWidgets('app lock on: the lock screen shows first', (tester) async {
    final store = MemorySecureStore();
    signedIn(store);
    store.values['app_lock_pin_hash'] = hashPin('2468');
    final s = await tester.runAsync(() => services(store));
    await pumpApp(tester, s!);
    expect(find.text('Enter your PIN'), findsOneWidget);
    expect(find.text('Hi, Mama'), findsNothing);
    await finish(tester, s);
  });

  test('conflict values: money as pesos, others as is', () {
    expect(formatConflictValue('amount_minor', '124000', 'empty', 'en'), '₱1,240.00');
    expect(formatConflictValue('name', '"Water"', 'empty', 'en'), 'Water');
    expect(formatConflictValue('name', null, 'empty', 'en'), 'empty');
  });
}
