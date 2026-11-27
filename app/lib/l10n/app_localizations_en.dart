// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HomeSync';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get signInCaption => 'Use the account the owner made for you.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get sharedTabletToggle => 'This is the shared household tablet';

  @override
  String get sharedTabletHint =>
      'Family members switch with their own 4-digit PIN.';

  @override
  String get signInButton => 'Sign in';

  @override
  String get signInFailed => 'Email or password is incorrect.';

  @override
  String get noConnection =>
      'Can\'t reach HomeSync. Check the connection and try again.';

  @override
  String get deviceNameAndroid => 'Android phone';

  @override
  String get deviceNameWeb => 'Web browser';

  @override
  String get lockTitle => 'Enter your PIN';

  @override
  String get useBiometrics => 'Use fingerprint or face';

  @override
  String get biometricReason => 'Unlock HomeSync';

  @override
  String get wrongPin => 'That PIN is not right.';

  @override
  String tooManyTries(int seconds) {
    return 'Too many tries. Try again in $seconds s.';
  }

  @override
  String get profilesTitle => 'Who\'s using the tablet?';

  @override
  String get profileNoPin => 'No PIN yet. Ask the owner to set one.';

  @override
  String get tabletPinTitle => 'Your tablet PIN';

  @override
  String get tabletPinCaption =>
      'Choose a 4-digit PIN to switch back to yourself on this tablet.';

  @override
  String enterPinFor(String name) {
    return 'PIN for $name';
  }

  @override
  String homeGreeting(String name) {
    return 'Hi, $name';
  }

  @override
  String get homeCaption => 'Everything here works offline.';

  @override
  String get modulesComingSoon => 'More modules are on the way.';

  @override
  String get syncSyncing => 'Syncing…';

  @override
  String get syncNever => 'Not synced yet';

  @override
  String syncLast(String time) {
    return 'Last synced $time';
  }

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes waiting',
      one: '1 change waiting',
    );
    return '$_temp0';
  }

  @override
  String syncRetry(String time) {
    return 'Couldn\'t sync. Trying again at $time.';
  }

  @override
  String get syncUpgrade =>
      'Update the app to keep syncing. Your data on this device is safe.';

  @override
  String get syncSignedOut =>
      'This device was signed out. Sign in again to sync.';

  @override
  String get syncNow => 'Sync now';

  @override
  String get conflictInboxTitle => 'Conflict inbox';

  @override
  String conflictInboxCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes to review',
      one: '1 change to review',
      zero: 'Nothing to review',
    );
    return '$_temp0';
  }

  @override
  String conflictSummary(String field, String entity) {
    return '$field · $entity';
  }

  @override
  String conflictKept(String value, String name) {
    return 'Now: $value (by $name)';
  }

  @override
  String conflictLost(String value, String name) {
    return 'Overwritten: $value (by $name)';
  }

  @override
  String get keep => 'Keep';

  @override
  String get revert => 'Put back';

  @override
  String get syncErrorsTitle => 'Changes that didn\'t sync';

  @override
  String syncErrorsCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count problems',
      one: '1 problem',
      zero: 'No problems',
    );
    return '$_temp0';
  }

  @override
  String syncErrorLine(String entity, String error) {
    return '$entity: $error';
  }

  @override
  String get dismiss => 'Dismiss';

  @override
  String get appLockTitle => 'App lock';

  @override
  String get appLockOn => 'On';

  @override
  String get appLockOff => 'Off';

  @override
  String get setPinTitle => 'Choose a 4-digit PIN';

  @override
  String get confirmPinTitle => 'Enter the PIN again';

  @override
  String get pinsDontMatch => 'The PINs don\'t match.';

  @override
  String get unlockWithBiometrics => 'Also unlock with fingerprint or face';

  @override
  String get turnOff => 'Turn off';

  @override
  String get switchProfile => 'Switch person';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutConfirm =>
      'Sign out of this device? Changes not synced yet stay on this device.';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get someone => 'someone';

  @override
  String get emptyValue => 'empty';

  @override
  String get pendingMarker => 'Waiting to sync';

  @override
  String get conflictMarker => 'Needs review';

  @override
  String get membersTitle => 'Household members';

  @override
  String membersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
    );
    return '$_temp0';
  }

  @override
  String get membersCaption => 'Who records things in this home.';

  @override
  String get membersOwnerOnly => 'Only the owner can manage household members.';

  @override
  String get memberAdd => 'Add person';

  @override
  String get memberEdit => 'Edit';

  @override
  String get memberName => 'Name';

  @override
  String get memberNameRequired => 'Enter a name.';

  @override
  String get memberRole => 'Role';

  @override
  String get memberColor => 'Colour';

  @override
  String get memberNoPin => 'no tablet PIN';

  @override
  String get memberHasPin => 'tablet PIN set';

  @override
  String get memberSetPin => 'Set tablet PIN';

  @override
  String get memberChangePin => 'Change tablet PIN';

  @override
  String get memberClearPin => 'Remove tablet PIN';

  @override
  String get memberRemove => 'Remove';

  @override
  String memberRemoveConfirm(String name) {
    return 'Remove $name from the household? What they recorded stays.';
  }

  @override
  String get roleOwner => 'Owner';

  @override
  String get roleAdult => 'Adult';

  @override
  String get roleTeen => 'Teen';

  @override
  String get roleChild => 'Child';

  @override
  String get roleHelper => 'Helper';

  @override
  String get roleViewer => 'Viewer';

  @override
  String get pantryModule => 'Pantry & grocery';

  @override
  String pantryModuleCaption(int toBuy, int low) {
    return '$toBuy to buy · $low running low';
  }

  @override
  String get groceryTab => 'Grocery list';

  @override
  String get pantryTab => 'Pantry';

  @override
  String groceryToBuy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count to buy',
      one: '1 to buy',
      zero: 'Nothing to buy',
    );
    return '$_temp0';
  }

  @override
  String pantryLowCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items running low in the pantry.',
      one: '1 item running low in the pantry.',
      zero: 'Pantry is stocked.',
    );
    return '$_temp0';
  }

  @override
  String get groceryAddHint => 'Add to the list, e.g. eggs';

  @override
  String get groceryAdd => 'Add';

  @override
  String get groceryEmpty => 'The list is empty.';

  @override
  String get groceryBought => 'Bought';

  @override
  String get groceryClearBought => 'Clear bought';

  @override
  String get groceryEditTitle => 'Edit item';

  @override
  String get groceryQuantity => 'How much';

  @override
  String get groceryQuantityHint => 'e.g. 1 tray, 2 kg';

  @override
  String get groceryStore => 'Store';

  @override
  String get groceryStoreHint => 'e.g. palengke, SM';

  @override
  String get groceryRemove => 'Remove from list';

  @override
  String groceryBoughtOn(String date) {
    return 'Bought $date';
  }

  @override
  String get groceryChangeDate => 'Change the date bought';

  @override
  String get groceryToday => 'Today';

  @override
  String get groceryYesterday => 'Yesterday';

  @override
  String get groceryHistory => 'Past groceries';

  @override
  String groceryHistoryFigure(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'Nothing bought',
    );
    return '$_temp0';
  }

  @override
  String groceryHistoryCaption(String month) {
    return 'bought in $month';
  }

  @override
  String get groceryHistoryEmpty =>
      'Nothing bought yet. Items you tick off show here by the day they were bought.';

  @override
  String groceryDayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get groceryBuyAgain => 'Add to the list again';

  @override
  String get groceryTomorrow => 'Tomorrow';

  @override
  String get groceryNoDate => 'No date';

  @override
  String get grocerySetDate => 'Set date';

  @override
  String get groceryPlanHelp => 'When will you buy it?';

  @override
  String groceryPlanFor(String day) {
    return 'Shopping day: $day';
  }

  @override
  String get groceryChangePlan => 'Change the shopping day';

  @override
  String get groceryRemovePlan => 'Remove the date';

  @override
  String groceryNextShopping(String day) {
    return 'Next shopping: $day';
  }

  @override
  String get itemName => 'Name';

  @override
  String get itemNameRequired => 'Enter a name.';

  @override
  String get itemNote => 'Note';

  @override
  String get pantryAdd => 'Add pantry item';

  @override
  String get pantryEditTitle => 'Edit pantry item';

  @override
  String get pantryEmpty => 'Nothing in the pantry yet.';

  @override
  String get pantryQuantity => 'How many now';

  @override
  String get pantryCountNow => 'Count now';

  @override
  String get pantryUnit => 'Unit';

  @override
  String get pantryUnitHint => 'e.g. kg, can, pack';

  @override
  String get pantryMin => 'Running low at';

  @override
  String get pantryMinHelp => 'Leave empty to never mark it low.';

  @override
  String get pantryNumber => 'Enter a number, 0 or more.';

  @override
  String get pantryLocation => 'Where';

  @override
  String get pantryLocationHint => 'e.g. ref, cabinet';

  @override
  String get pantryNoExpiry => 'No expiry date';

  @override
  String pantryExpiresOn(String date) {
    return 'Expires $date';
  }

  @override
  String get pantryClearExpiry => 'Clear expiry date';

  @override
  String get pantryExpired => 'Expired';

  @override
  String pantryExpiresIn(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Expires in $days days',
      one: 'Expires tomorrow',
      zero: 'Expires today',
    );
    return '$_temp0';
  }

  @override
  String get pantryLow => 'Running low';

  @override
  String pantryUseOne(String name) {
    return 'Use one $name';
  }

  @override
  String pantryAddOne(String name) {
    return 'Add one $name';
  }

  @override
  String get pantryToGrocery => 'Add to grocery list';

  @override
  String get pantryAddedToList => 'Added to the grocery list.';

  @override
  String get pantryAlreadyOnList => 'Already on the grocery list.';

  @override
  String get pantryRemove => 'Remove from pantry';

  @override
  String get budgetModule => 'Budget';

  @override
  String budgetTileLeft(String amount) {
    return '$amount left this month';
  }

  @override
  String budgetTileOver(String amount) {
    return '$amount over this month';
  }

  @override
  String budgetTileSpent(String amount) {
    return '$amount spent this month';
  }

  @override
  String get budgetTileRecord => 'Record an expense';

  @override
  String budgetLeft(String amount) {
    return '$amount left';
  }

  @override
  String budgetOver(String amount) {
    return '$amount over';
  }

  @override
  String budgetSpent(String amount) {
    return '$amount spent';
  }

  @override
  String budgetSpentOf(String spent, String budget, String month) {
    return 'Spent $spent of $budget in $month.';
  }

  @override
  String budgetNoLimitsCaption(String month) {
    return 'Spent in $month. Set budgets to see what\'s left.';
  }

  @override
  String budgetMineCaption(String month) {
    return 'What you recorded in $month.';
  }

  @override
  String get budgetPrevMonth => 'Previous month';

  @override
  String get budgetNextMonth => 'Next month';

  @override
  String get budgetSetFirst => 'Set a monthly budget';

  @override
  String get budgetSetAnother => 'Budget another category';

  @override
  String budgetOf(String spent, String limit) {
    return '$spent of $limit';
  }

  @override
  String budgetNoLimit(String spent) {
    return '$spent · no budget';
  }

  @override
  String budgetLimitFor(String category) {
    return 'Monthly budget for $category';
  }

  @override
  String get budgetMonthlyLimit => 'Each month';

  @override
  String get budgetClear => 'No budget for this';

  @override
  String budgetMoneyIn(String amount) {
    return 'Money in this month: $amount';
  }

  @override
  String get budgetEntriesTitle => 'This month';

  @override
  String get budgetMyEntriesTitle => 'What you recorded';

  @override
  String get budgetNoEntries => 'Nothing recorded this month.';

  @override
  String get budgetAdd => 'Add';

  @override
  String get budgetRecordExpense => 'Record expense';

  @override
  String get budgetAddExpense => 'Money out';

  @override
  String get budgetAddIncome => 'Money in';

  @override
  String get budgetMoneyOut => 'Out';

  @override
  String get budgetMoneyInLabel => 'In';

  @override
  String get budgetNoteHint => 'e.g. palengke, Meralco';

  @override
  String get budgetAppendOnlyHint =>
      'Amount, category and date can\'t be changed. If they are wrong, remove this and add it again.';

  @override
  String get budgetRemoveEntry => 'Remove';

  @override
  String get amount => 'Amount';

  @override
  String get amountInvalid => 'Enter an amount, e.g. 250 or 1,240.50.';

  @override
  String get category => 'Category';

  @override
  String get categoryRequired => 'Pick a category.';

  @override
  String get catFood => 'Food & groceries';

  @override
  String get catUtilities => 'Utilities';

  @override
  String get catTransport => 'Transport';

  @override
  String get catSchool => 'School';

  @override
  String get catHealth => 'Health';

  @override
  String get catHousehold => 'Household';

  @override
  String get catLoad => 'Load & internet';

  @override
  String get catPersonal => 'Personal';

  @override
  String get catGiving => 'Giving';

  @override
  String get catIncome => 'Money in';

  @override
  String get catOther => 'Other';

  @override
  String get billsModule => 'Bills & subscriptions';

  @override
  String billsTileDue(String amount) {
    return '$amount to pay this month';
  }

  @override
  String billsTileOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bills overdue',
      one: '1 bill overdue',
    );
    return '$_temp0';
  }

  @override
  String get billsTileClear => 'Nothing left to pay this month';

  @override
  String billsToPay(String amount) {
    return '$amount to pay';
  }

  @override
  String get billsAllPaid => 'All paid';

  @override
  String billsOverdueCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count overdue. Pay them soon.',
      one: '1 overdue. Pay it soon.',
    );
    return '$_temp0';
  }

  @override
  String billsNextCaption(String name, String date) {
    return 'Next: $name, $date';
  }

  @override
  String get billsEmptyCaption => 'Add your bills to see what\'s due.';

  @override
  String get billsTab => 'Bills';

  @override
  String get subscriptionsTab => 'Subscriptions';

  @override
  String get billsEmpty =>
      'No bills yet. Add Meralco, water, rent or internet.';

  @override
  String get billsNoneDue => 'Nothing to pay right now.';

  @override
  String get billsPaidRecently => 'Paid recently';

  @override
  String get billAdd => 'Add bill';

  @override
  String get billEdit => 'Edit bill';

  @override
  String get billRemove => 'Remove bill';

  @override
  String get billNameHint => 'e.g. Meralco';

  @override
  String get billAmountHelp => 'Your best guess if it changes every month';

  @override
  String billDueLabel(String date) {
    return 'Due $date';
  }

  @override
  String get billRepeatMonthly => 'Every month';

  @override
  String get billRepeatHelp => 'When it\'s paid, next month\'s bill is added.';

  @override
  String get billMonthly => 'Monthly';

  @override
  String get billCategoryLabel => 'Recorded in Budget as';

  @override
  String get billNoDueDate => 'No due date';

  @override
  String billOverdueBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Overdue by $count days',
      one: 'Overdue by 1 day',
    );
    return '$_temp0';
  }

  @override
  String billDueIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Due in $count days',
      one: 'Due tomorrow',
      zero: 'Due today',
    );
    return '$_temp0';
  }

  @override
  String billDueOn(String date) {
    return 'Due $date';
  }

  @override
  String billPaidOn(String date) {
    return 'Paid $date';
  }

  @override
  String get billAmountPaid => 'Amount paid';

  @override
  String billPayHint(String category) {
    return 'Recorded in Budget under $category.';
  }

  @override
  String get billMarkPaid => 'Mark paid';

  @override
  String get billUndoPaid => 'Undo paid';

  @override
  String get billUndoOnlyPayer =>
      'Only the person who marked it paid can undo it.';

  @override
  String get subscriptionAdd => 'Add subscription';

  @override
  String get subscriptionEdit => 'Edit subscription';

  @override
  String get subscriptionRemove => 'Remove subscription';

  @override
  String get subscriptionNameHint => 'e.g. Netflix';

  @override
  String get subscriptionPrice => 'Price';

  @override
  String get subscriptionMonthly => 'Monthly';

  @override
  String get subscriptionYearly => 'Yearly';

  @override
  String subscriptionNextLabel(String date) {
    return 'Next payment $date';
  }

  @override
  String get subscriptionsEmpty =>
      'No subscriptions yet. Add streaming, apps or memberships.';

  @override
  String subscriptionsMonthly(String amount) {
    return '$amount a month in subscriptions';
  }

  @override
  String subscriptionPayHint(String category) {
    return 'Records this payment in Budget under $category and moves the date to the next one.';
  }

  @override
  String get choresModule => 'Chores';

  @override
  String choresTileLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chores left today',
      one: '1 chore left today',
    );
    return '$_temp0';
  }

  @override
  String choresTileMine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count are yours today',
      one: '1 is yours today',
    );
    return '$_temp0';
  }

  @override
  String get choresTileDone => 'All done today';

  @override
  String get choresTileNone => 'Nothing today';

  @override
  String choresLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count left today',
      one: '1 left today',
    );
    return '$_temp0';
  }

  @override
  String get choresAllDone => 'All done today';

  @override
  String get choresNoneToday => 'Nothing today';

  @override
  String choresDoneCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count done so far. Salamat!',
      one: '1 done so far. Salamat!',
      zero: 'Tick a chore when it\'s done.',
    );
    return '$_temp0';
  }

  @override
  String choresMineCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count of them are yours.',
      one: '1 of them is yours.',
    );
    return '$_temp0';
  }

  @override
  String get choresToday => 'Today';

  @override
  String get choresComingUp => 'Coming up';

  @override
  String get choresEmpty => 'No chores for today.';

  @override
  String get choresEmptyAdult =>
      'No chores yet. Add dishes, laundry, sweeping or taking out the trash.';

  @override
  String get choreAdd => 'Add chore';

  @override
  String get choreEdit => 'Edit chore';

  @override
  String get choreRemove => 'Remove chore';

  @override
  String get choreNameHint => 'e.g. Wash the dishes';

  @override
  String get choreWho => 'Who does it';

  @override
  String get choreAnyone => 'Anyone';

  @override
  String get choreDaily => 'Daily';

  @override
  String get choreWeekly => 'Weekly';

  @override
  String get choreOnce => 'Once';

  @override
  String choreEveryWeekday(String day) {
    return 'Every $day';
  }

  @override
  String choreOnceOn(String date) {
    return 'Once, $date';
  }

  @override
  String choreDoneBy(String names) {
    return 'Done by $names';
  }

  @override
  String choreOverdueSince(String date) {
    return 'Not done since $date';
  }

  @override
  String get choreMarkDone => 'Mark done';

  @override
  String get choreUndo => 'Undo';

  @override
  String get choreUndoOnlyDoer => 'Only the person who did it can undo it.';

  @override
  String get calendarModule => 'Calendar';

  @override
  String calendarTileToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count things today',
      one: '1 thing today',
    );
    return '$_temp0';
  }

  @override
  String calendarTileNext(String title, String when) {
    return 'Next: $title, $when';
  }

  @override
  String get calendarTileNone => 'Nothing coming up';

  @override
  String get calendarFreeToday => 'Free today';

  @override
  String calendarCountToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count today',
      one: '1 today',
    );
    return '$_temp0';
  }

  @override
  String calendarNext(String title, String when) {
    return 'Next: $title, $when';
  }

  @override
  String get calendarNothingAhead => 'Nothing in the next 30 days';

  @override
  String get calendarToday => 'Today';

  @override
  String get calendarTomorrow => 'Tomorrow';

  @override
  String get calendarDayEmpty => 'Nothing on this day.';

  @override
  String get calendarComingUp => 'Coming up';

  @override
  String get calendarPrevMonth => 'Previous month';

  @override
  String get calendarNextMonth => 'Next month';

  @override
  String get calendarBillDue => 'Bill due';

  @override
  String get calendarSubscriptionDue => 'Subscription due';

  @override
  String get eventAdd => 'Add event';

  @override
  String get eventEdit => 'Edit event';

  @override
  String get eventRemove => 'Remove event';

  @override
  String get eventTitle => 'Title';

  @override
  String get eventTitleHint => 'e.g. Dentist, Lola\'s birthday';

  @override
  String get eventTitleRequired => 'Enter a title.';

  @override
  String get eventAllDay => 'All day';

  @override
  String get eventEndTime => 'End time';

  @override
  String get eventOnce => 'Once';

  @override
  String get eventWeekly => 'Weekly';

  @override
  String get eventMonthly => 'Monthly';

  @override
  String get eventYearly => 'Yearly';

  @override
  String get eventForWho => 'Who it\'s for';

  @override
  String get eventEveryone => 'Everyone';

  @override
  String get eventLocation => 'Where';

  @override
  String get eventNote => 'Note';

  @override
  String eventAddedBy(String name) {
    return 'Added by $name';
  }

  @override
  String versionLine(String app, String hub) {
    return 'Version $app · hub $hub';
  }

  @override
  String versionLineNoHub(String app) {
    return 'Version $app';
  }

  @override
  String get catDebt => 'Debt payments';

  @override
  String get debtsModule => 'Debts & loans';

  @override
  String debtsTileOwed(String amount) {
    return '$amount owed';
  }

  @override
  String debtsTileOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count payments overdue',
      one: '1 payment overdue',
    );
    return '$_temp0';
  }

  @override
  String get debtsTileNone => 'Nothing owed';

  @override
  String debtsOwed(String amount) {
    return '$amount owed';
  }

  @override
  String debtsOwedToUs(String amount) {
    return '$amount owed to you';
  }

  @override
  String get debtsNone => 'No debts';

  @override
  String debtsOverdueCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count payments overdue. Pay them soon.',
      one: '1 payment overdue. Pay it soon.',
    );
    return '$_temp0';
  }

  @override
  String get debtsEmptyCaption => 'Loans, cards, pawn tickets and money lent.';

  @override
  String get debtsYouOwe => 'You owe';

  @override
  String get debtsOwedToYou => 'Owed to you';

  @override
  String get debtsPaidOff => 'Paid off';

  @override
  String get debtsEmpty =>
      'Nothing here yet. Add a loan, credit card, pawn ticket or money you lent.';

  @override
  String get debtAdd => 'Add debt';

  @override
  String debtKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'loan': 'Loan',
      'card': 'Credit card',
      'pawn': 'Pawn ticket',
      'other': 'Money lent',
    });
    return '$_temp0';
  }

  @override
  String debtNameHint(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'loan': 'e.g. Pag-IBIG salary loan',
      'card': 'e.g. BPI card',
      'pawn': 'e.g. Gold ring',
      'other': 'e.g. Tito Ben',
    });
    return '$_temp0';
  }

  @override
  String debtCounterpartyLabel(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'loan': 'Lender (optional)',
      'card': 'Bank (optional)',
      'pawn': 'Pawnshop (optional)',
      'other': 'Who borrowed it (optional)',
    });
    return '$_temp0';
  }

  @override
  String debtReferenceLabel(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'pawn': 'Ticket number (optional)',
      'card': 'Last 4 digits (optional)',
      'other': 'Account or reference (optional)',
    });
    return '$_temp0';
  }

  @override
  String debtPrincipalLabel(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'loan': 'Amount borrowed',
      'card': 'Balance now',
      'pawn': 'Amount received',
      'other': 'Amount lent',
    });
    return '$_temp0';
  }

  @override
  String debtInstallmentLabel(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'card': 'Minimum due (optional)',
      'other': 'Monthly payment (optional)',
    });
    return '$_temp0';
  }

  @override
  String debtDueLabel(String kind, String date) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'pawn': 'Maturity: $date',
      'other': 'Next due: $date',
    });
    return '$_temp0';
  }

  @override
  String get debtSetDue => 'Set a due date';

  @override
  String get debtClearDue => 'No due date';

  @override
  String get debtRepeatMonthly => 'Due every month';

  @override
  String get debtRepeatHelp =>
      'Paying near the due date moves it to next month.';

  @override
  String get debtNote => 'Note (optional)';

  @override
  String debtBalanceLine(String balance, String principal) {
    return '$balance left of $principal';
  }

  @override
  String debtInstallmentLine(String amount) {
    return '$amount a month';
  }

  @override
  String debtPay(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'lent': 'Got paid back',
      'other': 'Record payment',
    });
    return '$_temp0';
  }

  @override
  String debtAddCharge(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'lent': 'Lent more',
      'card': 'Add charges',
      'other': 'Add to balance',
    });
    return '$_temp0';
  }

  @override
  String get debtInterestOnly => 'Interest only';

  @override
  String debtInterestHelp(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'pawn': 'Renewing the ticket? Pay the interest only: the balance stays.',
      'other': 'The balance stays the same.',
    });
    return '$_temp0';
  }

  @override
  String get debtPayHint => 'Recorded in Budget under Debt payments.';

  @override
  String get debtAmountPaid => 'Amount paid';

  @override
  String get debtAmountAdded => 'Amount added';

  @override
  String debtClose(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'pawn': 'Mark redeemed',
      'lent': 'Mark repaid',
      'other': 'Mark paid off',
    });
    return '$_temp0';
  }

  @override
  String debtClosedOn(String kind, String date) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'pawn': 'Redeemed $date',
      'lent': 'Repaid $date',
      'other': 'Paid off $date',
    });
    return '$_temp0';
  }

  @override
  String get debtReopen => 'Reopen';

  @override
  String get debtReopenOnlyCloser =>
      'Only the person who closed it can reopen it.';

  @override
  String get debtEdit => 'Edit debt';

  @override
  String get debtRemove => 'Remove debt';

  @override
  String get debtHistory => 'History';

  @override
  String get debtHistoryEmpty => 'Nothing recorded yet.';

  @override
  String debtEntry(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'payment': 'Payment',
      'interest': 'Interest',
      'other': 'Added',
    });
    return '$_temp0';
  }

  @override
  String get debtRemoveEntry => 'Remove this entry';
}
