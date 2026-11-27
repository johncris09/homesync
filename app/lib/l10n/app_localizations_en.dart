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
  String get eventColour => 'Colour';

  @override
  String get eventColourUbe => 'Ube';

  @override
  String get eventColourDagat => 'Dagat';

  @override
  String get eventColourDahon => 'Dahon';

  @override
  String get eventColourNarra => 'Narra';

  @override
  String get eventColourRosas => 'Rosas';

  @override
  String get eventColourTubig => 'Tubig';

  @override
  String get eventSeveralDays => 'Several days';

  @override
  String eventUntilDate(String date) {
    return 'Until $date';
  }

  @override
  String eventStartsAt(String time) {
    return 'Starts $time';
  }

  @override
  String eventUntilTime(String time) {
    return 'Until $time';
  }

  @override
  String eventDayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String eventTooLong(int days) {
    return 'Too long for this repeat: up to $days days';
  }

  @override
  String calendarRange(String from, String to) {
    return '$from – $to';
  }

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

  @override
  String get vaultModule => 'Document vault';

  @override
  String vaultTileDocs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count documents',
      one: '1 document',
      zero: 'Nothing kept yet',
    );
    return '$_temp0';
  }

  @override
  String vaultTileRenew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count to renew soon',
      one: '1 to renew soon',
    );
    return '$_temp0';
  }

  @override
  String get vaultTileSetUp => 'Not set up yet';

  @override
  String get vaultInboxNote =>
      'A vault document was changed on two devices. Open it in the vault to compare.';

  @override
  String vaultDocuments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count documents',
      one: '1 document',
      zero: 'No documents',
    );
    return '$_temp0';
  }

  @override
  String get vaultLockedCaption => 'Locked. Encrypted on this device.';

  @override
  String vaultLockedRenew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Locked · $count to renew soon',
      one: 'Locked · 1 to renew soon',
    );
    return '$_temp0';
  }

  @override
  String get vaultKeptSafe => 'Encrypted before it leaves this device';

  @override
  String vaultExpiresOn(String title, String date) {
    return '$title expires $date';
  }

  @override
  String get vaultRenewSoon => 'Renew soon';

  @override
  String get vaultEmpty =>
      'Add IDs, birth certificates, land titles, contracts and warranties. Only adults can open them.';

  @override
  String get vaultAdd => 'Add document';

  @override
  String get vaultEdit => 'Edit document';

  @override
  String get vaultDelete => 'Delete';

  @override
  String vaultDeleteConfirm(String title) {
    return 'Delete $title and its files from the vault?';
  }

  @override
  String get vaultLock => 'Lock';

  @override
  String get vaultUnlock => 'Unlock';

  @override
  String get vaultOpening => 'Opening the vault. This takes a few seconds.';

  @override
  String get vaultPassphrase => 'Vault passphrase';

  @override
  String get vaultPassphraseAgain => 'Passphrase again';

  @override
  String vaultPassphraseTooShort(int count) {
    return 'Use at least $count characters. A few words work well.';
  }

  @override
  String get vaultPassphrasesDontMatch => 'The passphrases don\'t match';

  @override
  String get vaultWrongPassphrase => 'That passphrase didn\'t open the vault';

  @override
  String get vaultAppLockHint =>
      'Turn on app lock on Home to open the vault with your PIN instead of the passphrase.';

  @override
  String get vaultBiometricReason => 'Open the document vault';

  @override
  String get vaultPinTitle => 'Enter your app PIN';

  @override
  String get vaultUseRecovery => 'Use recovery code';

  @override
  String get vaultRecoveryHint => 'K7QM-3XRT-9WHD-PC2E-VN6A-YB4F';

  @override
  String get vaultWrongRecovery => 'That recovery code didn\'t open the vault';

  @override
  String get vaultNewPassphrase => 'New vault passphrase';

  @override
  String get vaultNewPassphraseBody =>
      'Tell the other adults the new passphrase. Phones that already opened the vault keep working.';

  @override
  String get vaultChangePassphrase => 'Change passphrase';

  @override
  String get vaultNewRecoveryCode => 'New recovery code';

  @override
  String get vaultSetUpTitle => 'Set up the vault';

  @override
  String get vaultSetUpCaption => 'For IDs, titles and certificates';

  @override
  String get vaultSetUpBody =>
      'Choose a vault passphrase for the household and tell the other adults in person. Documents are encrypted on this device before they sync; the hub never sees them.';

  @override
  String get vaultSetUpButton => 'Set up';

  @override
  String get vaultSetUpOffline =>
      'Connect to the internet to set up the vault, so every device gets the same key.';

  @override
  String get vaultNotSetUp => 'The owner hasn\'t set up the vault yet.';

  @override
  String get vaultRecoveryTitle => 'Your recovery code';

  @override
  String get vaultRecoveryCaption =>
      'The only way back if the passphrase is lost';

  @override
  String get vaultRecoveryBody =>
      'Print it or write it down and keep it with the land titles. If the passphrase and this code are both lost, no one can open the documents again, not even HomeSync.';

  @override
  String get vaultRecoverySaved => 'I\'ve saved it somewhere safe';

  @override
  String get vaultFinish => 'Finish';

  @override
  String get vaultCopy => 'Copy';

  @override
  String get vaultKindId => 'ID';

  @override
  String get vaultKindCertificate => 'Certificate';

  @override
  String get vaultKindProperty => 'Property';

  @override
  String get vaultKindContract => 'Contract';

  @override
  String get vaultKindInsurance => 'Insurance';

  @override
  String get vaultKindWarranty => 'Warranty';

  @override
  String get vaultKindVehicle => 'Vehicle';

  @override
  String get vaultKindPawn => 'Pawn ticket';

  @override
  String get vaultKindOther => 'Other';

  @override
  String get vaultGroupId => 'IDs';

  @override
  String get vaultGroupCertificate => 'Certificates';

  @override
  String get vaultGroupProperty => 'Property';

  @override
  String get vaultGroupContract => 'Contracts';

  @override
  String get vaultGroupInsurance => 'Insurance';

  @override
  String get vaultGroupWarranty => 'Warranties';

  @override
  String get vaultGroupVehicle => 'Vehicles';

  @override
  String get vaultGroupPawn => 'Pawn tickets';

  @override
  String get vaultGroupOther => 'Other documents';

  @override
  String vaultTitleOf(String title, String name) {
    return '$title · $name';
  }

  @override
  String get vaultUnreadable => 'Can\'t open this document';

  @override
  String vaultDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '1 day left',
      zero: 'Expires today',
    );
    return '$_temp0';
  }

  @override
  String vaultExpiredDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Expired $count days ago',
      one: 'Expired yesterday',
    );
    return '$_temp0';
  }

  @override
  String vaultExpiresCaption(String date) {
    return 'Expires $date';
  }

  @override
  String vaultExpiredOn(String date) {
    return 'Expired $date';
  }

  @override
  String get vaultNumber => 'Number';

  @override
  String get vaultShowNumber => 'Show number';

  @override
  String get vaultHideNumber => 'Hide number';

  @override
  String get vaultKind => 'Kind';

  @override
  String get vaultWhose => 'Whose';

  @override
  String get vaultWholeFamily => 'Whole family';

  @override
  String get vaultIssuer => 'Issued by';

  @override
  String get vaultIssuerHint => 'DFA, PSA, LTO';

  @override
  String get vaultIssuedOn => 'Issued';

  @override
  String get vaultExpiresOnLabel => 'Expires';

  @override
  String get vaultNote => 'Note';

  @override
  String get vaultTitle => 'Name';

  @override
  String get vaultTitleHint => 'Passport';

  @override
  String get vaultTitleRequired => 'Give the document a name';

  @override
  String get vaultEncryptedNote =>
      'Name, number, issuer and note are encrypted. Kind, whose and the expiry date are not, so reminders work while the vault is locked.';

  @override
  String get vaultFiles => 'Photos and files';

  @override
  String get vaultTakePhoto => 'Take photo';

  @override
  String get vaultAddPhoto => 'Add photo';

  @override
  String get vaultAddPdf => 'Add PDF';

  @override
  String get vaultRemoveFile => 'Remove from the document';

  @override
  String get vaultFileTooBig => 'That file is over 20 MB';

  @override
  String get vaultFileOffline =>
      'Can\'t reach the hub to get this file. Try again when online.';

  @override
  String get vaultFileNotUploaded =>
      'This file hasn\'t been uploaded yet from the device that added it.';

  @override
  String get vaultConflictTitle => 'Changed on two devices at once';

  @override
  String get vaultUseOther => 'Use the other';

  @override
  String get vaultConflictOwner =>
      'The owner will choose which version to keep.';

  @override
  String get vehiclesModule => 'Vehicles';

  @override
  String get vehiclesTileNone => 'No vehicles yet';

  @override
  String get vehiclesTileNothingDue => 'Nothing due';

  @override
  String vehiclesTileOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count things overdue',
      one: '1 thing overdue',
    );
    return '$_temp0';
  }

  @override
  String get vehiclesNoneFigure => 'No vehicles yet';

  @override
  String get vehiclesEmptyCaption =>
      'Cars and motorcycles: papers, PMS and costs';

  @override
  String get vehiclesEmpty =>
      'Add your car or motorcycle to keep track of its registration, insurance, PMS and costs.';

  @override
  String get vehiclesNothingDue => 'Nothing due';

  @override
  String vehiclesNextFigure(String what, String when) {
    return '$what $when';
  }

  @override
  String vehiclesMoreOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more overdue',
      one: '1 more overdue',
    );
    return '$_temp0';
  }

  @override
  String vehiclesSpentLine(String amount) {
    return 'Spent this month: $amount';
  }

  @override
  String get vehiclesComingUp => 'Coming up';

  @override
  String get vehiclesOurs => 'Our vehicles';

  @override
  String vehicleDueKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'registration': 'Registration',
      'insurance': 'Insurance',
      'other': 'PMS',
    });
    return '$_temp0';
  }

  @override
  String vehicleDueOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'overdue by $count days',
      one: 'overdue by 1 day',
    );
    return '$_temp0';
  }

  @override
  String vehicleDueIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count days',
      one: 'due tomorrow',
      zero: 'due today',
    );
    return '$_temp0';
  }

  @override
  String vehicleDueOn(String date) {
    return 'on $date';
  }

  @override
  String vehicleKmLeft(String km) {
    return 'in $km km';
  }

  @override
  String vehicleKmPast(String km) {
    return '$km km past due';
  }

  @override
  String vehicleAtKm(String km) {
    return 'at $km km';
  }

  @override
  String vehicleOrAt(String km) {
    return 'or at $km km';
  }

  @override
  String vehicleOrOn(String date) {
    return 'or by $date';
  }

  @override
  String vehicleKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'car': 'Car',
      'other': 'Motorcycle',
    });
    return '$_temp0';
  }

  @override
  String vehicleLogKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'fuel': 'Fuel',
      'pms': 'PMS',
      'repair': 'Repair',
      'registration': 'Registration',
      'insurance': 'Insurance',
      'other': 'Odometer',
    });
    return '$_temp0';
  }

  @override
  String get vehicleAdd => 'Add vehicle';

  @override
  String get vehicleEdit => 'Edit vehicle';

  @override
  String get vehicleRemove => 'Remove vehicle';

  @override
  String get vehicleLogFuel => 'Log fuel';

  @override
  String get vehicleAddCost => 'Add cost';

  @override
  String get vehicleUpdateOdometer => 'Update odometer';

  @override
  String vehicleOdometer(String km) {
    return '$km km';
  }

  @override
  String get vehicleNoOdometer => 'No odometer reading yet';

  @override
  String vehicleLastReading(String km) {
    return 'Last reading $km km';
  }

  @override
  String vehicleNameHint(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'car': 'e.g. Innova',
      'other': 'e.g. Mio',
    });
    return '$_temp0';
  }

  @override
  String get vehiclePlate => 'Plate number (optional)';

  @override
  String get vehicleColor => 'Colour (optional)';

  @override
  String get vehicleOdometerLabel => 'Odometer';

  @override
  String get vehicleOdometerOptional => 'Odometer (optional)';

  @override
  String get vehicleOdometerInvalid => 'Enter a whole number above zero';

  @override
  String vehicleDueDateLabel(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'registration': 'LTO registration due',
      'insurance': 'Insurance due',
      'other': 'Next PMS date',
    });
    return '$_temp0';
  }

  @override
  String get vehicleNotSet => 'Not set';

  @override
  String get vehicleClearDate => 'Clear date';

  @override
  String get vehiclePmsKm => 'Next PMS at (optional)';

  @override
  String get vehiclePmsEveryMonths => 'PMS every how many months (optional)';

  @override
  String get vehiclePmsEveryKm => 'PMS every how many km (optional)';

  @override
  String get vehiclePmsHelp =>
      'PMS is due at its date or km, whichever comes first. Logging a PMS sets the next one from these.';

  @override
  String get vehicleNote => 'Note (optional)';

  @override
  String get vehicleAmount => 'Amount';

  @override
  String get vehicleLitres => 'Litres (optional)';

  @override
  String vehicleLitresLine(String litres) {
    return '$litres L';
  }

  @override
  String vehicleRenewHint(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'registration': 'Moves the registration due date one year on.',
      'insurance': 'Moves the insurance due date one year on.',
      'other': 'Sets the next PMS from its interval.',
    });
    return '$_temp0';
  }

  @override
  String get vehicleWhich => 'Which vehicle?';

  @override
  String get vehicleHistory => 'History';

  @override
  String get vehicleHistoryEmpty => 'Nothing recorded yet.';

  @override
  String get vehicleRemoveEntry => 'Remove this entry';

  @override
  String calendarVehicleDue(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'registration': 'Registration due',
      'insurance': 'Insurance due',
      'other': 'PMS due',
    });
    return '$_temp0';
  }

  @override
  String get healthModule => 'Health';

  @override
  String healthTileDosesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count doses left today',
      one: '1 dose left today',
    );
    return '$_temp0';
  }

  @override
  String healthTileLow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count medicines running low',
      one: '1 medicine running low',
    );
    return '$_temp0';
  }

  @override
  String healthTileCheckup(String title, String date) {
    return '$title $date';
  }

  @override
  String get healthTileNothing => 'No doses or checkups due';

  @override
  String get healthNoMedicines => 'No medicines yet';

  @override
  String get healthNoDosesToday => 'No doses today';

  @override
  String get healthEmptyCaption =>
      'Medicines, checkups and the family\'s health';

  @override
  String healthCheckupCaption(String title, String date) {
    return 'Next: $title on $date';
  }

  @override
  String get healthAllGiven => 'All doses given';

  @override
  String healthAllGivenCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count doses given today',
      one: '1 dose given today',
    );
    return '$_temp0';
  }

  @override
  String healthDosesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count doses left',
      one: '1 dose left',
    );
    return '$_temp0';
  }

  @override
  String healthNextDose(String what, String time) {
    return 'Next: $what at $time';
  }

  @override
  String get healthToday => 'Today';

  @override
  String get healthRunningLow => 'Running low';

  @override
  String get healthCheckups => 'Checkups and vaccines';

  @override
  String get healthNoCheckups => 'Nothing coming up.';

  @override
  String get healthMedicines => 'Medicines';

  @override
  String get healthMedicinesEmpty =>
      'Add the medicines the family takes to tick off doses and know when to restock.';

  @override
  String get healthFamily => 'Family';

  @override
  String get healthProfilesLocked =>
      'Open the vault to see blood types, allergies and conditions';

  @override
  String get healthProfilesNoVault =>
      'Set up the vault to keep health profiles';

  @override
  String doseGivenBy(String time, String name) {
    return '$time · given by $name';
  }

  @override
  String doseGivenByName(String name) {
    return 'Given by $name';
  }

  @override
  String get doseUndo => 'Undo this dose';

  @override
  String get medicineAdd => 'Add medicine';

  @override
  String get medicineEdit => 'Edit medicine';

  @override
  String get medicineRemove => 'Remove medicine';

  @override
  String medicineLeft(String count) {
    return '$count left';
  }

  @override
  String medicineExpires(String date) {
    return 'Expires $date';
  }

  @override
  String medicineExpired(String date) {
    return 'Expired $date';
  }

  @override
  String get medicineAddToList => 'Add to list';

  @override
  String get medicineForAnyone => 'Anyone';

  @override
  String get medicineAsNeeded => 'As needed';

  @override
  String medicineUntil(String date) {
    return 'until $date';
  }

  @override
  String medicineStockLine(String count, String unit) {
    return '$count $unit left';
  }

  @override
  String get medicineUnitDefault => 'tablets';

  @override
  String get medicineGiveDose => 'Give a dose';

  @override
  String get medicineRestock => 'Restock';

  @override
  String get medicineStockTake => 'Count what\'s left';

  @override
  String get medicineDoses => 'Doses';

  @override
  String get medicineDosesEmpty => 'No doses given yet.';

  @override
  String get medicineExtraDose => 'extra dose';

  @override
  String get medicineCounted => 'How many are left';

  @override
  String get medicineAdded => 'How many you bought';

  @override
  String get medicineCost => 'Cost (optional)';

  @override
  String get medicineNameHint => 'e.g. Losartan';

  @override
  String get medicineStrength => 'Strength (optional)';

  @override
  String get medicineForWhom => 'Who is it for?';

  @override
  String get medicineTimes => 'Dose times (optional)';

  @override
  String get medicineTimesHelp =>
      'Like 8:00, 20:00. Leave empty for as needed.';

  @override
  String get medicineTimesInvalid => 'Use times like 8:00 or 20:30';

  @override
  String get medicineStockNow => 'How many you have now';

  @override
  String get medicineMin => 'Running low at (optional)';

  @override
  String get medicineUnit => 'Unit (optional)';

  @override
  String get medicineEndsOn => 'Last day';

  @override
  String get medicineOngoing => 'Ongoing';

  @override
  String get medicineExpiry => 'Expiry date';

  @override
  String get checkupAdd => 'Add checkup';

  @override
  String get checkupEdit => 'Edit checkup';

  @override
  String get checkupRemove => 'Remove checkup';

  @override
  String checkupKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'vaccine': 'Vaccine',
      'other': 'Checkup',
    });
    return '$_temp0';
  }

  @override
  String checkupTitleHint(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'vaccine': 'e.g. Flu vaccine',
      'other': 'e.g. Cardiology checkup',
    });
    return '$_temp0';
  }

  @override
  String get checkupDate => 'Date';

  @override
  String get checkupTime => 'Time (optional)';

  @override
  String get checkupTimeHelp => 'Like 9:30 or 14:00';

  @override
  String get checkupPlace => 'Doctor or place (optional)';

  @override
  String get checkupCost => 'Cost (optional)';

  @override
  String get checkupMarkDone => 'Mark done';

  @override
  String calendarCheckupDue(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'vaccine': 'Vaccine',
      'other': 'Checkup',
    });
    return '$_temp0';
  }

  @override
  String profileTitle(String name) {
    return '$name\'s health';
  }

  @override
  String get profileSealedHelp =>
      'Only adults with the vault passphrase can read this.';

  @override
  String get profileEmpty => 'No profile yet';

  @override
  String profileBloodLine(String type) {
    return 'Blood type $type';
  }

  @override
  String profileAllergyLine(String what) {
    return 'Allergic: $what';
  }

  @override
  String get profileBlood => 'Blood type (optional)';

  @override
  String get profileAllergies => 'Allergies (optional)';

  @override
  String get profileConditions => 'Conditions (optional)';

  @override
  String get profileMaintenance => 'Maintenance medicines (optional)';

  @override
  String get profilePhilhealth => 'PhilHealth number (optional)';

  @override
  String get profileHmo => 'HMO and card number (optional)';

  @override
  String get profileDoctor => 'Doctor (optional)';

  @override
  String get rentModule => 'Rent';

  @override
  String get rentTileNone => 'No rentals yet';

  @override
  String get rentTileAllPaid => 'All paid this month';

  @override
  String rentTileToCollect(String amount) {
    return '$amount to collect';
  }

  @override
  String rentTileLate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tenants late',
      one: '1 tenant late',
    );
    return '$_temp0';
  }

  @override
  String get rentNoneFigure => 'No rentals yet';

  @override
  String get rentEmptyCaption => 'Rooms, houses and stalls you rent out';

  @override
  String get rentEmpty =>
      'Add a room, house or stall you rent out, then the tenant who stays there.';

  @override
  String rentToCollectFigure(String amount) {
    return '$amount to collect';
  }

  @override
  String get rentAllPaidFigure => 'All paid';

  @override
  String rentPaidCount(int paid, int total) {
    return '$paid of $total paid';
  }

  @override
  String rentOverdueCount(int count) {
    return '$count overdue';
  }

  @override
  String rentVacantCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vacant',
      one: '1 vacant',
    );
    return '$_temp0';
  }

  @override
  String get rentToCollect => 'To collect';

  @override
  String get rentPaidThisMonth => 'Paid this month';

  @override
  String get rentVacant => 'Vacant';

  @override
  String get rentVacantLine => 'Vacant · add a tenant';

  @override
  String rentOwesLine(String amount) {
    return 'Owes $amount';
  }

  @override
  String rentLeftOf(String left, String rent) {
    return '$left left of $rent';
  }

  @override
  String rentDueOn(String date) {
    return 'due $date';
  }

  @override
  String rentDaysLate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days late',
      one: '1 day late',
    );
    return '$_temp0';
  }

  @override
  String rentMovedOut(String date) {
    return 'moved out $date';
  }

  @override
  String rentPaidOn(String date) {
    return 'paid $date';
  }

  @override
  String rentAhead(String amount) {
    return '$amount paid ahead';
  }

  @override
  String get rentRecordPayment => 'Record payment';

  @override
  String get rentAddUnit => 'Add unit';

  @override
  String get rentEditUnit => 'Rename unit';

  @override
  String get rentRemoveUnit => 'Remove unit';

  @override
  String get rentUnitName => 'Unit name';

  @override
  String get rentUnitNameHint => 'Room 1, upstairs, stall 3';

  @override
  String get rentAddTenant => 'Add tenant';

  @override
  String get rentEditTenant => 'Edit tenant';

  @override
  String get rentRemoveTenant => 'Remove tenant';

  @override
  String get rentTenantName => 'Tenant name';

  @override
  String get rentPhone => 'Phone (optional)';

  @override
  String get rentMonthly => 'Monthly rent';

  @override
  String get rentChangeHint =>
      'A new rent applies from this month; earlier months keep the old one.';

  @override
  String get rentDueDay => 'Due day of the month';

  @override
  String get rentDueDayHelp =>
      '29, 30 or 31 falls on the last day of a shorter month';

  @override
  String get rentDueDayInvalid => 'Enter a day from 1 to 31';

  @override
  String get rentStartsOn => 'Moved in';

  @override
  String get rentDeposit => 'Deposit (optional)';

  @override
  String get rentNote => 'Note (optional)';

  @override
  String rentEveryLine(String amount, int day) {
    return '$amount a month, due on day $day';
  }

  @override
  String rentSince(String date) {
    return 'Since $date';
  }

  @override
  String rentDepositLine(String amount) {
    return 'Deposit $amount';
  }

  @override
  String rentDepositReturned(String returned, String deposit) {
    return 'Deposit: $returned of $deposit returned';
  }

  @override
  String get rentCall => 'Call';

  @override
  String get rentText => 'Text';

  @override
  String get rentWhich => 'Which tenant?';

  @override
  String get rentAmount => 'Amount';

  @override
  String get rentPaidOnLabel => 'Paid on';

  @override
  String rentMethod(String method) {
    String _temp0 = intl.Intl.selectLogic(method, {
      'cash': 'Cash',
      'gcash': 'GCash',
      'bank': 'Bank',
      'other': 'Other',
    });
    return '$_temp0';
  }

  @override
  String get rentPayHint =>
      'Pays the oldest month first. Recorded as money in on the Budget.';

  @override
  String get rentWaive => 'Waive rent';

  @override
  String get rentWaiveHint =>
      'Forgiven rent counts as paid but is not money in.';

  @override
  String get rentMoveOut => 'Move out';

  @override
  String get rentMoveOutDate => 'Moving out on';

  @override
  String get rentDepositBack => 'Deposit returned';

  @override
  String get rentMoveOutHint =>
      'Rent stops after this month. The unit shows as vacant; anything still owed stays on the list.';

  @override
  String get rentUndoMoveOut => 'Undo move out';

  @override
  String get rentHistory => 'Payments';

  @override
  String get rentHistoryEmpty => 'No payments yet';

  @override
  String rentKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'waived': 'Waived',
      'other': 'Payment',
    });
    return '$_temp0';
  }

  @override
  String get rentRemoveEntry => 'Remove entry';

  @override
  String calendarRentDue(String amount) {
    return 'Rent due · $amount';
  }

  @override
  String get inventoryModule => 'Inventory';

  @override
  String get inventoryTileNone => 'Nothing listed yet';

  @override
  String inventoryTileItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String inventoryTileAttention(int count, int attention) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0 · $attention need a look';
  }

  @override
  String get inventoryNoneFigure => 'No items yet';

  @override
  String inventoryCountFigure(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get inventoryEmptyCaption =>
      'Appliances, gadgets, furniture and tools';

  @override
  String inventoryWorth(String amount) {
    return 'worth $amount';
  }

  @override
  String inventoryRoomCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rooms',
      one: '1 room',
      zero: 'no rooms set',
    );
    return '$_temp0';
  }

  @override
  String inventoryAttentionCount(int count) {
    return '$count need a look';
  }

  @override
  String get inventoryEmpty =>
      'List what the household owns: where it is, when it was bought, its warranty and who borrowed it.';

  @override
  String get inventoryEmptyHelper =>
      'Nothing is listed yet. An adult can add items.';

  @override
  String get inventoryAddItem => 'Add item';

  @override
  String get inventoryEditItem => 'Edit item';

  @override
  String get inventoryRemoveItem => 'Remove item';

  @override
  String inventoryRemoveTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String get inventoryRemoveBody =>
      'It disappears from every phone in the household.';

  @override
  String get inventorySearch => 'Search name, brand, serial or who has it';

  @override
  String get inventoryClearSearch => 'Clear search';

  @override
  String get inventoryNoMatch => 'Nothing matches.';

  @override
  String get inventoryNeedsAttention => 'Needs a look';

  @override
  String get inventoryNoRoom => 'No room set';

  @override
  String inventoryWarrantyEnds(String date) {
    return 'Warranty ends $date';
  }

  @override
  String inventoryWarrantyUntil(String date) {
    return 'Under warranty until $date';
  }

  @override
  String inventoryWarrantyEnded(String date) {
    return 'Warranty ended $date';
  }

  @override
  String inventoryLentTo(String name) {
    return 'Lent to $name';
  }

  @override
  String inventoryLentSince(String name, String date) {
    return 'Lent to $name since $date';
  }

  @override
  String inventoryBoughtOn(String date) {
    return 'Bought $date';
  }

  @override
  String inventorySerialLine(String serial) {
    return 'S/N $serial';
  }

  @override
  String inventoryCategory(String category) {
    String _temp0 = intl.Intl.selectLogic(category, {
      'appliance': 'Appliance',
      'electronics': 'Electronics',
      'furniture': 'Furniture',
      'tools': 'Tools',
      'other': 'Other',
    });
    return '$_temp0';
  }

  @override
  String get inventoryPhotoNotHere => 'Photo not here yet · try again';

  @override
  String get inventoryPhotoTooBig => 'That photo is too big.';

  @override
  String get inventoryTakePhoto => 'Take photo';

  @override
  String get inventoryRetakePhoto => 'New photo';

  @override
  String get inventoryChoosePhoto => 'Choose photo';

  @override
  String get inventoryRemovePhoto => 'Remove photo';

  @override
  String get inventoryLend => 'Lend';

  @override
  String get inventoryReturned => 'Returned';

  @override
  String inventoryLendTitle(String name) {
    return 'Lend $name';
  }

  @override
  String get inventoryLendWho => 'Who borrowed it';

  @override
  String get inventoryLendSince => 'Since';

  @override
  String get inventoryItemName => 'Name';

  @override
  String get inventoryItemNameHint => 'e.g. Ref, aircon, electric fan';

  @override
  String get inventoryRoom => 'Room';

  @override
  String get inventoryDefaultRooms => 'Sala,Kusina,Kwarto,CR,Garahe,Bodega';

  @override
  String get inventoryBrand => 'Brand';

  @override
  String get inventoryModel => 'Model';

  @override
  String get inventorySerial => 'Serial number';

  @override
  String get inventoryBought => 'Bought on';

  @override
  String get inventoryPrice => 'Price paid';

  @override
  String get inventoryWarrantyField => 'Warranty until';

  @override
  String get inventoryNote => 'Note';

  @override
  String get inventoryNotSet => 'Not set';

  @override
  String get inventoryClearDate => 'Clear date';

  @override
  String get calendarWarrantyEnds => 'Warranty ends';

  @override
  String get emergencyModule => 'Emergency';

  @override
  String emergencyTileHelp(String name) {
    return '$name needs help';
  }

  @override
  String emergencyTileSafe(int safe, int total) {
    return '$safe of $total safe today';
  }

  @override
  String emergencyTileBags(int ready, int total) {
    return '$ready of $total go-bags packed';
  }

  @override
  String get emergencyTileSetUp => 'Contacts, meeting point, go-bags';

  @override
  String emergencyNeedsHelpFigure(String name) {
    return '$name needs help';
  }

  @override
  String emergencyManyNeedHelp(int count) {
    return '$count need help';
  }

  @override
  String emergencySafeFigure(int safe, int total) {
    return '$safe of $total safe';
  }

  @override
  String emergencySafeCaption(int safe, int total) {
    return '$safe of $total checked in safe';
  }

  @override
  String get emergencyLast24h => 'Check-ins from the last 24 hours';

  @override
  String get emergencyReadyFigure => 'Be ready';

  @override
  String get emergencyReadyCaption => 'Tap I\'m safe when something happens';

  @override
  String emergencyBagsPacked(int ready, int total) {
    return '$ready of $total go-bags packed';
  }

  @override
  String get emergencyImSafe => 'I\'m safe';

  @override
  String get emergencyNeedHelp => 'Need help';

  @override
  String get emergencyCheckedInSafe =>
      'Checked in as safe. It reaches everyone when you have signal.';

  @override
  String get emergencyWho => 'Who\'s checked in';

  @override
  String get emergencyStatusSafe => 'Safe';

  @override
  String get emergencyStatusHelp => 'Needs help';

  @override
  String emergencyLastCheckin(String date) {
    return 'Last check-in $date';
  }

  @override
  String get emergencyNoCheckin => 'No check-in yet';

  @override
  String get emergencyHelpNote => 'Where are you, what\'s wrong?';

  @override
  String get emergencyHelpNoteHint => 'e.g. Stuck at school, road flooded';

  @override
  String get emergencyHelpSyncs =>
      'Saved on this phone now and sent as soon as there is signal. In danger, call 911.';

  @override
  String get emergencySendHelp => 'Send';

  @override
  String get emergencyCall => 'Numbers to call';

  @override
  String emergencyHotline(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'emergency': 'National emergency hotline',
      'redCross': 'Philippine Red Cross',
      'other': 'Hotline',
    });
    return '$_temp0';
  }

  @override
  String emergencyCallNumber(String number) {
    return 'Call $number';
  }

  @override
  String emergencyContactKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'family': 'Family',
      'barangay': 'Barangay',
      'hospital': 'Hospital',
      'doctor': 'Doctor',
      'other': 'Other',
    });
    return '$_temp0';
  }

  @override
  String get emergencyAddContact => 'Add contact';

  @override
  String get emergencyEditContact => 'Edit contact';

  @override
  String get emergencyRemoveContact => 'Remove contact';

  @override
  String get emergencyContactName => 'Name';

  @override
  String get emergencyContactPhone => 'Phone number';

  @override
  String get emergencyPhoneInvalid => 'Enter a phone number.';

  @override
  String get emergencyNote => 'Note';

  @override
  String get emergencyWhereToMeet => 'Where to meet';

  @override
  String get emergencyNoPlan => 'No meeting point yet';

  @override
  String get emergencyNoPlanAdult =>
      'Agree where everyone goes if you\'re apart.';

  @override
  String get emergencyNoPlanOthers => 'Ask an adult to set one.';

  @override
  String get emergencyMeetingPoint => 'Meeting point nearby';

  @override
  String get emergencyMeetingPointHint => 'e.g. the covered court';

  @override
  String get emergencyMeetingPointFar => 'Meeting point outside the area';

  @override
  String get emergencyMeetingPointFarHint => 'e.g. Lola\'s house in town';

  @override
  String get emergencyEvacuationCenter => 'Evacuation centre';

  @override
  String get emergencyEvacuationCenterHint => 'e.g. the elementary school';

  @override
  String get emergencyEditPlan => 'Edit meeting points';

  @override
  String get emergencyGoBags => 'Go-bags';

  @override
  String get emergencyHouseholdBag => 'Household';

  @override
  String get emergencyUnknownMember => 'Member';

  @override
  String emergencyBagTitle(String name) {
    return '$name\'s go-bag';
  }

  @override
  String get emergencyBagEmpty => 'Nothing listed yet';

  @override
  String emergencyBagPacked(int packed, int total) {
    return '$packed of $total packed';
  }

  @override
  String emergencyBagExpiring(int count) {
    return '$count to replace';
  }

  @override
  String get emergencyAddToBag => 'Add an item';

  @override
  String get emergencyAddStarter => 'Add the starter list';

  @override
  String emergencyStarterItem(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'water': 'Drinking water',
      'food': 'Ready-to-eat food',
      'flashlight': 'Flashlight',
      'batteries': 'Extra batteries',
      'whistle': 'Whistle',
      'firstAid': 'First aid kit',
      'medicines': 'Maintenance medicines',
      'ids': 'Copies of IDs',
      'cash': 'Cash in small bills',
      'powerBank': 'Power bank',
      'clothes': 'Change of clothes',
      'raincoat': 'Raincoat',
      'other': 'Item',
    });
    return '$_temp0';
  }

  @override
  String get emergencyEditItem => 'Edit item';

  @override
  String get emergencyRemoveItem => 'Remove item';

  @override
  String get emergencyItemName => 'Item';

  @override
  String get emergencyExpiresField => 'Expires';

  @override
  String get emergencyNoExpiry => 'No expiry';

  @override
  String emergencyExpires(String date) {
    return 'expires $date';
  }

  @override
  String emergencyExpired(String date) {
    return 'expired $date';
  }

  @override
  String get emergencyChecklists => 'Be ready for';

  @override
  String emergencyHazard(String hazard) {
    String _temp0 = intl.Intl.selectLogic(hazard, {
      'typhoon': 'Typhoon',
      'flood': 'Flood',
      'earthquake': 'Earthquake',
      'other': 'Hazard',
    });
    return '$_temp0';
  }

  @override
  String emergencyHazardTitle(String hazard) {
    String _temp0 = intl.Intl.selectLogic(hazard, {
      'typhoon': 'Before a typhoon',
      'flood': 'Before a flood',
      'earthquake': 'Before an earthquake',
      'other': 'Checklist',
    });
    return '$_temp0';
  }

  @override
  String emergencyChecksDone(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get emergencyClearChecks => 'Clear ticks';

  @override
  String emergencyCheckItem(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'typhoon_charge': 'Charge phones and power banks',
      'typhoon_water': 'Store drinking water for at least 3 days',
      'typhoon_food': 'Stock ready-to-eat food for at least 3 days',
      'typhoon_secure': 'Secure the roof, windows and loose things outside',
      'typhoon_drains': 'Clear drains and gutters',
      'typhoon_bags': 'Keep go-bags by the door',
      'typhoon_center': 'Know the way to the evacuation centre',
      'typhoon_updates': 'Follow PAGASA updates on radio or TV',
      'flood_upHigh': 'Move appliances, documents and valuables up high',
      'flood_power': 'Switch off the main power if water starts coming in',
      'flood_documents': 'Keep IDs and documents in a waterproof bag',
      'flood_noWading': 'Don\'t walk or drive through floodwater',
      'flood_highGround': 'Know the way to higher ground',
      'flood_bags': 'Keep go-bags by the door',
      'earthquake_furniture': 'Fasten tall furniture and shelves to the wall',
      'earthquake_safeSpots':
          'Know the safe spot in each room, like under a sturdy table',
      'earthquake_drill': 'Practise Duck, Cover and Hold',
      'earthquake_shutOff': 'Know how to turn off gas, water and power',
      'earthquake_bedside': 'Keep shoes and a flashlight by each bed',
      'earthquake_meet': 'Agree where to meet outside',
      'other': 'Item',
    });
    return '$_temp0';
  }

  @override
  String get emergencyWorksOffline =>
      'Everything here is on this phone and works without signal.';
}
