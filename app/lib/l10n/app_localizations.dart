import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'HomeSync'**
  String get appTitle;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInTitle;

  /// No description provided for @signInCaption.
  ///
  /// In en, this message translates to:
  /// **'Use the account the owner made for you.'**
  String get signInCaption;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @sharedTabletToggle.
  ///
  /// In en, this message translates to:
  /// **'This is the shared household tablet'**
  String get sharedTabletToggle;

  /// No description provided for @sharedTabletHint.
  ///
  /// In en, this message translates to:
  /// **'Family members switch with their own 4-digit PIN.'**
  String get sharedTabletHint;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInButton;

  /// No description provided for @signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect.'**
  String get signInFailed;

  /// No description provided for @noConnection.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach HomeSync. Check the connection and try again.'**
  String get noConnection;

  /// No description provided for @deviceNameAndroid.
  ///
  /// In en, this message translates to:
  /// **'Android phone'**
  String get deviceNameAndroid;

  /// No description provided for @deviceNameWeb.
  ///
  /// In en, this message translates to:
  /// **'Web browser'**
  String get deviceNameWeb;

  /// No description provided for @lockTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get lockTitle;

  /// No description provided for @useBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or face'**
  String get useBiometrics;

  /// No description provided for @biometricReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock HomeSync'**
  String get biometricReason;

  /// No description provided for @wrongPin.
  ///
  /// In en, this message translates to:
  /// **'That PIN is not right.'**
  String get wrongPin;

  /// No description provided for @tooManyTries.
  ///
  /// In en, this message translates to:
  /// **'Too many tries. Try again in {seconds} s.'**
  String tooManyTries(int seconds);

  /// No description provided for @profilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Who\'s using the tablet?'**
  String get profilesTitle;

  /// No description provided for @profileNoPin.
  ///
  /// In en, this message translates to:
  /// **'No PIN yet. Ask the owner to set one.'**
  String get profileNoPin;

  /// No description provided for @tabletPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Your tablet PIN'**
  String get tabletPinTitle;

  /// No description provided for @tabletPinCaption.
  ///
  /// In en, this message translates to:
  /// **'Choose a 4-digit PIN to switch back to yourself on this tablet.'**
  String get tabletPinCaption;

  /// No description provided for @enterPinFor.
  ///
  /// In en, this message translates to:
  /// **'PIN for {name}'**
  String enterPinFor(String name);

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeCaption.
  ///
  /// In en, this message translates to:
  /// **'Everything here works offline.'**
  String get homeCaption;

  /// No description provided for @modulesComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Budget, bills, chores, calendar and pantry arrive in Phase 1.'**
  String get modulesComingSoon;

  /// No description provided for @syncSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncSyncing;

  /// No description provided for @syncNever.
  ///
  /// In en, this message translates to:
  /// **'Not synced yet'**
  String get syncNever;

  /// No description provided for @syncLast.
  ///
  /// In en, this message translates to:
  /// **'Last synced {time}'**
  String syncLast(String time);

  /// No description provided for @syncPending.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change waiting} other{{count} changes waiting}}'**
  String syncPending(int count);

  /// No description provided for @syncRetry.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sync. Trying again at {time}.'**
  String syncRetry(String time);

  /// No description provided for @syncUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Update the app to keep syncing. Your data on this device is safe.'**
  String get syncUpgrade;

  /// No description provided for @syncSignedOut.
  ///
  /// In en, this message translates to:
  /// **'This device was signed out. Sign in again to sync.'**
  String get syncSignedOut;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @conflictInboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Conflict inbox'**
  String get conflictInboxTitle;

  /// No description provided for @conflictInboxCaption.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing to review} =1{1 change to review} other{{count} changes to review}}'**
  String conflictInboxCaption(int count);

  /// No description provided for @conflictSummary.
  ///
  /// In en, this message translates to:
  /// **'{field} · {entity}'**
  String conflictSummary(String field, String entity);

  /// No description provided for @conflictKept.
  ///
  /// In en, this message translates to:
  /// **'Now: {value} (by {name})'**
  String conflictKept(String value, String name);

  /// No description provided for @conflictLost.
  ///
  /// In en, this message translates to:
  /// **'Overwritten: {value} (by {name})'**
  String conflictLost(String value, String name);

  /// No description provided for @keep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get keep;

  /// No description provided for @revert.
  ///
  /// In en, this message translates to:
  /// **'Put back'**
  String get revert;

  /// No description provided for @syncErrorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Changes that didn\'t sync'**
  String get syncErrorsTitle;

  /// No description provided for @syncErrorsCaption.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No problems} =1{1 problem} other{{count} problems}}'**
  String syncErrorsCaption(int count);

  /// No description provided for @syncErrorLine.
  ///
  /// In en, this message translates to:
  /// **'{entity}: {error}'**
  String syncErrorLine(String entity, String error);

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @appLockTitle.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get appLockTitle;

  /// No description provided for @appLockOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get appLockOn;

  /// No description provided for @appLockOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get appLockOff;

  /// No description provided for @setPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a 4-digit PIN'**
  String get setPinTitle;

  /// No description provided for @confirmPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the PIN again'**
  String get confirmPinTitle;

  /// No description provided for @pinsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'The PINs don\'t match.'**
  String get pinsDontMatch;

  /// No description provided for @unlockWithBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Also unlock with fingerprint or face'**
  String get unlockWithBiometrics;

  /// No description provided for @turnOff.
  ///
  /// In en, this message translates to:
  /// **'Turn off'**
  String get turnOff;

  /// No description provided for @switchProfile.
  ///
  /// In en, this message translates to:
  /// **'Switch person'**
  String get switchProfile;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sign out of this device? Changes not synced yet stay on this device.'**
  String get signOutConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @someone.
  ///
  /// In en, this message translates to:
  /// **'someone'**
  String get someone;

  /// No description provided for @emptyValue.
  ///
  /// In en, this message translates to:
  /// **'empty'**
  String get emptyValue;

  /// No description provided for @pendingMarker.
  ///
  /// In en, this message translates to:
  /// **'Waiting to sync'**
  String get pendingMarker;

  /// No description provided for @conflictMarker.
  ///
  /// In en, this message translates to:
  /// **'Needs review'**
  String get conflictMarker;

  /// No description provided for @membersTitle.
  ///
  /// In en, this message translates to:
  /// **'Household members'**
  String get membersTitle;

  /// No description provided for @membersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person} other{{count} people}}'**
  String membersCount(int count);

  /// No description provided for @membersCaption.
  ///
  /// In en, this message translates to:
  /// **'Who records things in this home.'**
  String get membersCaption;

  /// No description provided for @membersOwnerOnly.
  ///
  /// In en, this message translates to:
  /// **'Only the owner can manage household members.'**
  String get membersOwnerOnly;

  /// No description provided for @memberAdd.
  ///
  /// In en, this message translates to:
  /// **'Add person'**
  String get memberAdd;

  /// No description provided for @memberEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get memberEdit;

  /// No description provided for @memberName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get memberName;

  /// No description provided for @memberNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name.'**
  String get memberNameRequired;

  /// No description provided for @memberRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get memberRole;

  /// No description provided for @memberColor.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get memberColor;

  /// No description provided for @memberNoPin.
  ///
  /// In en, this message translates to:
  /// **'no tablet PIN'**
  String get memberNoPin;

  /// No description provided for @memberHasPin.
  ///
  /// In en, this message translates to:
  /// **'tablet PIN set'**
  String get memberHasPin;

  /// No description provided for @memberSetPin.
  ///
  /// In en, this message translates to:
  /// **'Set tablet PIN'**
  String get memberSetPin;

  /// No description provided for @memberChangePin.
  ///
  /// In en, this message translates to:
  /// **'Change tablet PIN'**
  String get memberChangePin;

  /// No description provided for @memberClearPin.
  ///
  /// In en, this message translates to:
  /// **'Remove tablet PIN'**
  String get memberClearPin;

  /// No description provided for @memberRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get memberRemove;

  /// No description provided for @memberRemoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from the household? What they recorded stays.'**
  String memberRemoveConfirm(String name);

  /// No description provided for @roleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get roleOwner;

  /// No description provided for @roleAdult.
  ///
  /// In en, this message translates to:
  /// **'Adult'**
  String get roleAdult;

  /// No description provided for @roleTeen.
  ///
  /// In en, this message translates to:
  /// **'Teen'**
  String get roleTeen;

  /// No description provided for @roleChild.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get roleChild;

  /// No description provided for @roleHelper.
  ///
  /// In en, this message translates to:
  /// **'Helper'**
  String get roleHelper;

  /// No description provided for @roleViewer.
  ///
  /// In en, this message translates to:
  /// **'Viewer'**
  String get roleViewer;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
