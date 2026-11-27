import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync/core/auth/secure_store.dart';

import '../app_test.dart' as app;
import 'budget_screen_test.dart' show helper, open, signedInAs, tapText;

Future<void> tapKey(WidgetTester tester, String key) async {
  await tester.ensureVisible(find.byKey(Key(key)));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('adult checks in, adds a contact and meeting point, fills a go-bag, ticks a checklist', (tester) async {
    final store = MemorySecureStore();
    app.signedIn(store);
    final s = (await tester.runAsync(() => open(store)))!;
    await app.pumpApp(tester, s);
    expect(find.text('Contacts, meeting point, go-bags'), findsOneWidget, reason: 'home tile');

    await tapText(tester, 'Emergency');
    expect(find.text('Be ready'), findsOneWidget, reason: 'header');
    expect(find.text('No check-in yet'), findsOneWidget);
    expect(find.text('911'), findsOneWidget, reason: 'built-in hotline');

    await tester.tap(find.byKey(const Key('checkin-safe')));
    await tester.pumpAndSettle();
    expect(find.text('1 of 1 safe'), findsOneWidget);
    expect(find.textContaining('Safe · '), findsOneWidget);

    // A contact.
    await tapKey(tester, 'add-contact');
    await tester.enterText(find.byKey(const Key('contact-name')), 'Barangay hall');
    await tester.tap(find.byKey(const Key('contact-save')));
    await tester.pumpAndSettle();
    expect(find.text('Enter a phone number.'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('contact-phone')), '0917 555 0199');
    await tester.tap(find.byKey(const Key('kind-barangay')));
    await tester.tap(find.byKey(const Key('contact-save')));
    await tester.pumpAndSettle();
    expect(find.text('Barangay · 0917 555 0199'), findsOneWidget);

    // Meeting points.
    await tapKey(tester, 'edit-plan');
    await tester.enterText(find.byKey(const Key('plan-near')), 'Covered court');
    await tester.enterText(find.byKey(const Key('plan-center')), 'Elementary school');
    await tester.tap(find.byKey(const Key('plan-save')));
    await tester.pumpAndSettle();
    expect(find.text('Covered court'), findsOneWidget);
    expect(find.text('Evacuation centre'), findsOneWidget);

    // The household go-bag from the starter list.
    await tapText(tester, 'Household');
    expect(find.text('Household go-bag'), findsOneWidget);
    await tester.tap(find.byKey(const Key('bag-starter')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('bag-count')), findsOneWidget);
    expect(find.text('0 of 12 packed'), findsWidgets);
    await tester.tap(find.byKey(const Key('bag-item-Flashlight')));
    await tester.pumpAndSettle();
    expect(find.text('1 of 12 packed'), findsWidgets);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    // A typhoon checklist item.
    await tapText(tester, 'Typhoon');
    expect(find.text('Before a typhoon'), findsOneWidget);
    await tester.tap(find.byKey(const Key('check-charge')));
    await tester.pumpAndSettle();
    expect(find.text('1 of 8 done'), findsWidgets);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tester.fling(find.byType(ListView).first, const Offset(0, 3000), 3000);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('1 of 1 safe today'), findsOneWidget, reason: 'home tile, now at the top');
    await app.finish(tester, s);
  });

  testWidgets('a helper asks for help and ticks only their own and the household bag', (tester) async {
    final store = MemorySecureStore();
    signedInAs(store, helper);
    final s = (await tester.runAsync(() async {
      final s = await open(store);
      await s.writer.insert('members', {'name': 'Ate Joy', 'role': 'helper'}, id: helper.memberId);
      return s;
    }))!;
    await app.pumpApp(tester, s);
    await tapText(tester, 'Emergency');

    expect(find.byKey(const Key('add-contact')), findsNothing);
    expect(find.byKey(const Key('edit-plan')), findsNothing);
    expect(find.text('Ask an adult to set one.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('checkin-help')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('help-note')), 'Road flooded');
    await tester.tap(find.byKey(const Key('help-send')));
    await tester.pumpAndSettle();
    expect(find.text('Ate Joy needs help'), findsOneWidget, reason: 'header');
    expect(find.textContaining('Road flooded'), findsOneWidget);

    // Mama's bag: read only. Her own: can add.
    await tapText(tester, 'Mama');
    expect(find.byKey(const Key('bag-add')), findsNothing);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    await tapText(tester, 'Ate Joy');
    expect(find.text("Ate Joy's go-bag"), findsOneWidget);
    await tester.enterText(find.byKey(const Key('bag-add')), 'Phone charger');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('0 of 1 packed'), findsWidgets);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tapText(tester, 'Flood');
    final box = tester.widget<CheckboxListTile>(find.byKey(const Key('check-power')));
    expect(box.onChanged, isNull, reason: 'only adults tick hazard checklists');
    await app.finish(tester, s);
  });
}
