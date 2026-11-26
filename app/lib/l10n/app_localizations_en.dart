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
  String get modulesComingSoon =>
      'Budget, bills, chores, calendar and pantry arrive in Phase 1.';

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
}
