import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/auth/auth_service.dart';
import 'package:homesync/core/auth/secure_store.dart';
import 'package:homesync/features/maintenance/maintenance_repository.dart';

import '../app_test.dart' as app;
import 'budget_screen_test.dart' show open, signedInAs, tapText;

Future<void> tapKey(WidgetTester tester, String key) async {
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.byKey(Key(key)));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('adult adds a contractor and a task, marks it done with a cost, logs a repair', (tester) async {
    final store = MemorySecureStore();
    app.signedIn(store);
    final s = (await tester.runAsync(() => open(store)))!;
    await app.pumpApp(tester, s);
    expect(find.text('Upkeep, repairs and contractors'), findsOneWidget, reason: 'home tile');

    await tapText(tester, 'Home maintenance');
    expect(find.text('Upkeep, repairs and the people you call'), findsOneWidget, reason: 'header caption');

    // A contractor.
    await tapText(tester, 'Contractors');
    await tapKey(tester, 'add-contractor');
    await tester.tap(find.byKey(const Key('contractor-save')));
    await tester.pumpAndSettle();
    expect(find.text('Enter a name.'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('contractor-name')), 'Mang Ben');
    await tapKey(tester, 'trade-aircon');
    await tester.enterText(find.byKey(const Key('contractor-phone')), '0917 555 0123');
    await tapKey(tester, 'contractor-save');
    expect(find.text('Aircon technician · 0917 555 0123'), findsOneWidget);
    expect(find.byKey(const Key('call-Mang Ben')), findsOneWidget);

    // A task from the suggestions, due today.
    await tapText(tester, 'Upkeep');
    await tapKey(tester, 'add-task');
    await tapKey(tester, 'starter-aircon');
    await tapKey(tester, 'task-save');
    expect(find.text('Aircon cleaning today'), findsOneWidget, reason: 'header');
    expect(find.text('Due today'), findsOneWidget);

    // Done, with a cost.
    await tapKey(tester, 'done-Aircon cleaning');
    expect(find.byKey(const Key('done-next')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('cost')), '1500');
    await tapKey(tester, 'done-save');
    expect(find.text('Every 3 months'), findsOneWidget);
    expect(find.textContaining('Aircon cleaning on '), findsOneWidget, reason: 'header: next in 3 months');
    expect(find.text('1 task · ₱1,500 this year'), findsOneWidget);

    final ledger = await tester.runAsync(() => s.db.select(s.db.transactions).get());
    expect(ledger!.single.amountMinor, -150000);
    expect(ledger.single.sourceType, maintenanceSource);

    // A repair.
    await tapText(tester, 'History');
    expect(find.byKey(const Key('log-Aircon cleaning')), findsOneWidget);
    expect(find.text('₱1,500'), findsOneWidget);
    await tapKey(tester, 'log-repair');
    await tester.enterText(find.byKey(const Key('repair-title')), 'Broken faucet');
    await tapKey(tester, 'area-plumbing');
    await tester.enterText(find.byKey(const Key('cost')), '450');
    await tapKey(tester, 'repair-save');
    expect(find.byKey(const Key('log-Broken faucet')), findsOneWidget);
    expect(find.text('1 task · ₱1,950 this year'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.textContaining('Aircon cleaning · on '), findsOneWidget, reason: 'home tile');
    await app.finish(tester, s);
  });

  testWidgets('a teen sees what is due and the contractors but cannot change anything', (tester) async {
    final store = MemorySecureStore();
    const teen = Profile(
      memberId: '01900000-0000-7000-8000-0000000000cc',
      name: 'Ben',
      role: 'teen',
      deviceId: 'c0000000-0000-7000-8000-00000000000c',
    );
    signedInAs(store, teen);
    final s = (await tester.runAsync(() async {
      final s = await open(store);
      final repo = MaintenanceRepository(s.db, s.writer);
      await repo.addContractor(name: 'Mang Ben', trade: 'aircon', phone: '0917 555 0123');
      await repo.addTask(
        name: 'Pest control',
        area: 'pest',
        everyMonths: 6,
        nextDueOn: DateTime.now().subtract(const Duration(days: 20)),
      );
      await repo.addRepair(title: 'Broken faucet', area: 'plumbing', costMinor: 45000);
      return s;
    }))!;
    await app.pumpApp(tester, s);
    expect(find.text('1 task overdue'), findsOneWidget, reason: 'home tile');
    await tapText(tester, 'Home maintenance');

    expect(find.text('1 overdue'), findsOneWidget, reason: 'header');
    expect(find.text('1 task'), findsOneWidget, reason: 'no money in the caption');
    expect(find.byKey(const Key('add-task')), findsNothing);
    expect(find.byKey(const Key('done-Pest control')), findsNothing);

    await tapText(tester, 'History');
    expect(find.byKey(const Key('log-Broken faucet')), findsOneWidget);
    expect(find.byKey(const Key('cost-Broken faucet')), findsNothing);
    await tapText(tester, 'Contractors');
    expect(find.byKey(const Key('call-Mang Ben')), findsOneWidget);
    expect(find.byKey(const Key('add-contractor')), findsNothing);
    await app.finish(tester, s);
  });
}
