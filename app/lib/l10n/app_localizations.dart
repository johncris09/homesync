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
  /// **'More modules are on the way.'**
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

  /// No description provided for @pantryModule.
  ///
  /// In en, this message translates to:
  /// **'Pantry & grocery'**
  String get pantryModule;

  /// No description provided for @pantryModuleCaption.
  ///
  /// In en, this message translates to:
  /// **'{toBuy} to buy · {low} running low'**
  String pantryModuleCaption(int toBuy, int low);

  /// No description provided for @groceryTab.
  ///
  /// In en, this message translates to:
  /// **'Grocery list'**
  String get groceryTab;

  /// No description provided for @pantryTab.
  ///
  /// In en, this message translates to:
  /// **'Pantry'**
  String get pantryTab;

  /// No description provided for @groceryToBuy.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing to buy} =1{1 to buy} other{{count} to buy}}'**
  String groceryToBuy(int count);

  /// No description provided for @pantryLowCaption.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Pantry is stocked.} =1{1 item running low in the pantry.} other{{count} items running low in the pantry.}}'**
  String pantryLowCaption(int count);

  /// No description provided for @groceryAddHint.
  ///
  /// In en, this message translates to:
  /// **'Add to the list, e.g. eggs'**
  String get groceryAddHint;

  /// No description provided for @groceryAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get groceryAdd;

  /// No description provided for @groceryEmpty.
  ///
  /// In en, this message translates to:
  /// **'The list is empty.'**
  String get groceryEmpty;

  /// No description provided for @groceryBought.
  ///
  /// In en, this message translates to:
  /// **'Bought'**
  String get groceryBought;

  /// No description provided for @groceryClearBought.
  ///
  /// In en, this message translates to:
  /// **'Clear bought'**
  String get groceryClearBought;

  /// No description provided for @groceryFor.
  ///
  /// In en, this message translates to:
  /// **'asked by {name}'**
  String groceryFor(String name);

  /// No description provided for @groceryEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get groceryEditTitle;

  /// No description provided for @groceryQuantity.
  ///
  /// In en, this message translates to:
  /// **'How much'**
  String get groceryQuantity;

  /// No description provided for @groceryQuantityHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1 tray, 2 kg'**
  String get groceryQuantityHint;

  /// No description provided for @groceryStore.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get groceryStore;

  /// No description provided for @groceryStoreHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. palengke, SM'**
  String get groceryStoreHint;

  /// No description provided for @groceryRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from list'**
  String get groceryRemove;

  /// No description provided for @groceryBoughtOn.
  ///
  /// In en, this message translates to:
  /// **'Bought {date}'**
  String groceryBoughtOn(String date);

  /// No description provided for @groceryChangeDate.
  ///
  /// In en, this message translates to:
  /// **'Change the date bought'**
  String get groceryChangeDate;

  /// No description provided for @groceryToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get groceryToday;

  /// No description provided for @groceryYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get groceryYesterday;

  /// No description provided for @groceryHistory.
  ///
  /// In en, this message translates to:
  /// **'Past groceries'**
  String get groceryHistory;

  /// No description provided for @groceryHistoryFigure.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing bought} =1{1 item} other{{count} items}}'**
  String groceryHistoryFigure(int count);

  /// No description provided for @groceryHistoryCaption.
  ///
  /// In en, this message translates to:
  /// **'bought in {month}'**
  String groceryHistoryCaption(String month);

  /// No description provided for @groceryHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing bought yet. Items you tick off show here by the day they were bought.'**
  String get groceryHistoryEmpty;

  /// No description provided for @groceryDayCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String groceryDayCount(int count);

  /// No description provided for @groceryBuyAgain.
  ///
  /// In en, this message translates to:
  /// **'Add to the list again'**
  String get groceryBuyAgain;

  /// No description provided for @groceryTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get groceryTomorrow;

  /// No description provided for @groceryNoDate.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get groceryNoDate;

  /// No description provided for @grocerySetDate.
  ///
  /// In en, this message translates to:
  /// **'Set date'**
  String get grocerySetDate;

  /// No description provided for @groceryPlanHelp.
  ///
  /// In en, this message translates to:
  /// **'When will you buy it?'**
  String get groceryPlanHelp;

  /// No description provided for @groceryPlanFor.
  ///
  /// In en, this message translates to:
  /// **'Shopping day: {day}'**
  String groceryPlanFor(String day);

  /// No description provided for @groceryChangePlan.
  ///
  /// In en, this message translates to:
  /// **'Change the shopping day'**
  String get groceryChangePlan;

  /// No description provided for @groceryRemovePlan.
  ///
  /// In en, this message translates to:
  /// **'Remove the date'**
  String get groceryRemovePlan;

  /// No description provided for @groceryNextShopping.
  ///
  /// In en, this message translates to:
  /// **'Next shopping: {day}'**
  String groceryNextShopping(String day);

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get itemName;

  /// No description provided for @itemNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name.'**
  String get itemNameRequired;

  /// No description provided for @itemNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get itemNote;

  /// No description provided for @pantryAdd.
  ///
  /// In en, this message translates to:
  /// **'Add pantry item'**
  String get pantryAdd;

  /// No description provided for @pantryEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit pantry item'**
  String get pantryEditTitle;

  /// No description provided for @pantryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing in the pantry yet.'**
  String get pantryEmpty;

  /// No description provided for @pantryQuantity.
  ///
  /// In en, this message translates to:
  /// **'How many now'**
  String get pantryQuantity;

  /// No description provided for @pantryCountNow.
  ///
  /// In en, this message translates to:
  /// **'Count now'**
  String get pantryCountNow;

  /// No description provided for @pantryUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get pantryUnit;

  /// No description provided for @pantryUnitHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. kg, can, pack'**
  String get pantryUnitHint;

  /// No description provided for @pantryMin.
  ///
  /// In en, this message translates to:
  /// **'Running low at'**
  String get pantryMin;

  /// No description provided for @pantryMinHelp.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to never mark it low.'**
  String get pantryMinHelp;

  /// No description provided for @pantryNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a number, 0 or more.'**
  String get pantryNumber;

  /// No description provided for @pantryLocation.
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get pantryLocation;

  /// No description provided for @pantryLocationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. ref, cabinet'**
  String get pantryLocationHint;

  /// No description provided for @pantryNoExpiry.
  ///
  /// In en, this message translates to:
  /// **'No expiry date'**
  String get pantryNoExpiry;

  /// No description provided for @pantryExpiresOn.
  ///
  /// In en, this message translates to:
  /// **'Expires {date}'**
  String pantryExpiresOn(String date);

  /// No description provided for @pantryClearExpiry.
  ///
  /// In en, this message translates to:
  /// **'Clear expiry date'**
  String get pantryClearExpiry;

  /// No description provided for @pantryExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get pantryExpired;

  /// No description provided for @pantryExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Expires today} =1{Expires tomorrow} other{Expires in {days} days}}'**
  String pantryExpiresIn(int days);

  /// No description provided for @pantryLow.
  ///
  /// In en, this message translates to:
  /// **'Running low'**
  String get pantryLow;

  /// No description provided for @pantryUseOne.
  ///
  /// In en, this message translates to:
  /// **'Use one {name}'**
  String pantryUseOne(String name);

  /// No description provided for @pantryAddOne.
  ///
  /// In en, this message translates to:
  /// **'Add one {name}'**
  String pantryAddOne(String name);

  /// No description provided for @pantryToGrocery.
  ///
  /// In en, this message translates to:
  /// **'Add to grocery list'**
  String get pantryToGrocery;

  /// No description provided for @pantryAddedToList.
  ///
  /// In en, this message translates to:
  /// **'Added to the grocery list.'**
  String get pantryAddedToList;

  /// No description provided for @pantryAlreadyOnList.
  ///
  /// In en, this message translates to:
  /// **'Already on the grocery list.'**
  String get pantryAlreadyOnList;

  /// No description provided for @pantryRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from pantry'**
  String get pantryRemove;

  /// No description provided for @budgetModule.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budgetModule;

  /// No description provided for @budgetTileLeft.
  ///
  /// In en, this message translates to:
  /// **'{amount} left this month'**
  String budgetTileLeft(String amount);

  /// No description provided for @budgetTileOver.
  ///
  /// In en, this message translates to:
  /// **'{amount} over this month'**
  String budgetTileOver(String amount);

  /// No description provided for @budgetTileSpent.
  ///
  /// In en, this message translates to:
  /// **'{amount} spent this month'**
  String budgetTileSpent(String amount);

  /// No description provided for @budgetTileRecord.
  ///
  /// In en, this message translates to:
  /// **'Record an expense'**
  String get budgetTileRecord;

  /// No description provided for @budgetLeft.
  ///
  /// In en, this message translates to:
  /// **'{amount} left'**
  String budgetLeft(String amount);

  /// No description provided for @budgetOver.
  ///
  /// In en, this message translates to:
  /// **'{amount} over'**
  String budgetOver(String amount);

  /// No description provided for @budgetSpent.
  ///
  /// In en, this message translates to:
  /// **'{amount} spent'**
  String budgetSpent(String amount);

  /// No description provided for @budgetSpentOf.
  ///
  /// In en, this message translates to:
  /// **'Spent {spent} of {budget} in {month}.'**
  String budgetSpentOf(String spent, String budget, String month);

  /// No description provided for @budgetNoLimitsCaption.
  ///
  /// In en, this message translates to:
  /// **'Spent in {month}. Set budgets to see what\'s left.'**
  String budgetNoLimitsCaption(String month);

  /// No description provided for @budgetMineCaption.
  ///
  /// In en, this message translates to:
  /// **'What you recorded in {month}.'**
  String budgetMineCaption(String month);

  /// No description provided for @budgetPrevMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get budgetPrevMonth;

  /// No description provided for @budgetNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get budgetNextMonth;

  /// No description provided for @budgetSetFirst.
  ///
  /// In en, this message translates to:
  /// **'Set a monthly budget'**
  String get budgetSetFirst;

  /// No description provided for @budgetSetAnother.
  ///
  /// In en, this message translates to:
  /// **'Budget another category'**
  String get budgetSetAnother;

  /// No description provided for @budgetOf.
  ///
  /// In en, this message translates to:
  /// **'{spent} of {limit}'**
  String budgetOf(String spent, String limit);

  /// No description provided for @budgetNoLimit.
  ///
  /// In en, this message translates to:
  /// **'{spent} · no budget'**
  String budgetNoLimit(String spent);

  /// No description provided for @budgetLimitFor.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget for {category}'**
  String budgetLimitFor(String category);

  /// No description provided for @budgetMonthlyLimit.
  ///
  /// In en, this message translates to:
  /// **'Each month'**
  String get budgetMonthlyLimit;

  /// No description provided for @budgetClear.
  ///
  /// In en, this message translates to:
  /// **'No budget for this'**
  String get budgetClear;

  /// No description provided for @budgetMoneyIn.
  ///
  /// In en, this message translates to:
  /// **'Money in this month: {amount}'**
  String budgetMoneyIn(String amount);

  /// No description provided for @budgetEntriesTitle.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get budgetEntriesTitle;

  /// No description provided for @budgetMyEntriesTitle.
  ///
  /// In en, this message translates to:
  /// **'What you recorded'**
  String get budgetMyEntriesTitle;

  /// No description provided for @budgetNoEntries.
  ///
  /// In en, this message translates to:
  /// **'Nothing recorded this month.'**
  String get budgetNoEntries;

  /// No description provided for @budgetAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get budgetAdd;

  /// No description provided for @budgetRecordExpense.
  ///
  /// In en, this message translates to:
  /// **'Record expense'**
  String get budgetRecordExpense;

  /// No description provided for @budgetAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Money out'**
  String get budgetAddExpense;

  /// No description provided for @budgetAddIncome.
  ///
  /// In en, this message translates to:
  /// **'Money in'**
  String get budgetAddIncome;

  /// No description provided for @budgetMoneyOut.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get budgetMoneyOut;

  /// No description provided for @budgetMoneyInLabel.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get budgetMoneyInLabel;

  /// No description provided for @budgetNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. palengke, Meralco'**
  String get budgetNoteHint;

  /// No description provided for @budgetAppendOnlyHint.
  ///
  /// In en, this message translates to:
  /// **'Amount, category and date can\'t be changed. If they are wrong, remove this and add it again.'**
  String get budgetAppendOnlyHint;

  /// No description provided for @budgetRemoveEntry.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get budgetRemoveEntry;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @amountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount, e.g. 250 or 1,240.50.'**
  String get amountInvalid;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @categoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Pick a category.'**
  String get categoryRequired;

  /// No description provided for @catFood.
  ///
  /// In en, this message translates to:
  /// **'Food & groceries'**
  String get catFood;

  /// No description provided for @catUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get catUtilities;

  /// No description provided for @catTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get catTransport;

  /// No description provided for @catSchool.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get catSchool;

  /// No description provided for @catHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get catHealth;

  /// No description provided for @catHousehold.
  ///
  /// In en, this message translates to:
  /// **'Household'**
  String get catHousehold;

  /// No description provided for @catLoad.
  ///
  /// In en, this message translates to:
  /// **'Load & internet'**
  String get catLoad;

  /// No description provided for @catPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get catPersonal;

  /// No description provided for @catGiving.
  ///
  /// In en, this message translates to:
  /// **'Giving'**
  String get catGiving;

  /// No description provided for @catIncome.
  ///
  /// In en, this message translates to:
  /// **'Money in'**
  String get catIncome;

  /// No description provided for @catOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOther;

  /// No description provided for @billsModule.
  ///
  /// In en, this message translates to:
  /// **'Bills & subscriptions'**
  String get billsModule;

  /// No description provided for @billsTileDue.
  ///
  /// In en, this message translates to:
  /// **'{amount} to pay this month'**
  String billsTileDue(String amount);

  /// No description provided for @billsTileOverdue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 bill overdue} other{{count} bills overdue}}'**
  String billsTileOverdue(int count);

  /// No description provided for @billsTileClear.
  ///
  /// In en, this message translates to:
  /// **'Nothing left to pay this month'**
  String get billsTileClear;

  /// No description provided for @billsToPay.
  ///
  /// In en, this message translates to:
  /// **'{amount} to pay'**
  String billsToPay(String amount);

  /// No description provided for @billsAllPaid.
  ///
  /// In en, this message translates to:
  /// **'All paid'**
  String get billsAllPaid;

  /// No description provided for @billsOverdueCaption.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 overdue. Pay it soon.} other{{count} overdue. Pay them soon.}}'**
  String billsOverdueCaption(int count);

  /// No description provided for @billsNextCaption.
  ///
  /// In en, this message translates to:
  /// **'Next: {name}, {date}'**
  String billsNextCaption(String name, String date);

  /// No description provided for @billsEmptyCaption.
  ///
  /// In en, this message translates to:
  /// **'Add your bills to see what\'s due.'**
  String get billsEmptyCaption;

  /// No description provided for @billsTab.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get billsTab;

  /// No description provided for @subscriptionsTab.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptionsTab;

  /// No description provided for @billsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No bills yet. Add Meralco, water, rent or internet.'**
  String get billsEmpty;

  /// No description provided for @billsNoneDue.
  ///
  /// In en, this message translates to:
  /// **'Nothing to pay right now.'**
  String get billsNoneDue;

  /// No description provided for @billsPaidRecently.
  ///
  /// In en, this message translates to:
  /// **'Paid recently'**
  String get billsPaidRecently;

  /// No description provided for @billAdd.
  ///
  /// In en, this message translates to:
  /// **'Add bill'**
  String get billAdd;

  /// No description provided for @billEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit bill'**
  String get billEdit;

  /// No description provided for @billRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove bill'**
  String get billRemove;

  /// No description provided for @billNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Meralco'**
  String get billNameHint;

  /// No description provided for @billAmountHelp.
  ///
  /// In en, this message translates to:
  /// **'Your best guess if it changes every month'**
  String get billAmountHelp;

  /// No description provided for @billDueLabel.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String billDueLabel(String date);

  /// No description provided for @billRepeatMonthly.
  ///
  /// In en, this message translates to:
  /// **'Every month'**
  String get billRepeatMonthly;

  /// No description provided for @billRepeatHelp.
  ///
  /// In en, this message translates to:
  /// **'When it\'s paid, next month\'s bill is added.'**
  String get billRepeatHelp;

  /// No description provided for @billMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get billMonthly;

  /// No description provided for @billCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Recorded in Budget as'**
  String get billCategoryLabel;

  /// No description provided for @billNoDueDate.
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get billNoDueDate;

  /// No description provided for @billOverdueBy.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Overdue by 1 day} other{Overdue by {count} days}}'**
  String billOverdueBy(int count);

  /// No description provided for @billDueIn.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Due today} =1{Due tomorrow} other{Due in {count} days}}'**
  String billDueIn(int count);

  /// No description provided for @billDueOn.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String billDueOn(String date);

  /// No description provided for @billPaidOn.
  ///
  /// In en, this message translates to:
  /// **'Paid {date}'**
  String billPaidOn(String date);

  /// No description provided for @billAmountPaid.
  ///
  /// In en, this message translates to:
  /// **'Amount paid'**
  String get billAmountPaid;

  /// No description provided for @billPayHint.
  ///
  /// In en, this message translates to:
  /// **'Recorded in Budget under {category}.'**
  String billPayHint(String category);

  /// No description provided for @billMarkPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark paid'**
  String get billMarkPaid;

  /// No description provided for @billUndoPaid.
  ///
  /// In en, this message translates to:
  /// **'Undo paid'**
  String get billUndoPaid;

  /// No description provided for @billUndoOnlyPayer.
  ///
  /// In en, this message translates to:
  /// **'Only the person who marked it paid can undo it.'**
  String get billUndoOnlyPayer;

  /// No description provided for @subscriptionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add subscription'**
  String get subscriptionAdd;

  /// No description provided for @subscriptionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit subscription'**
  String get subscriptionEdit;

  /// No description provided for @subscriptionRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove subscription'**
  String get subscriptionRemove;

  /// No description provided for @subscriptionNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Netflix'**
  String get subscriptionNameHint;

  /// No description provided for @subscriptionPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get subscriptionPrice;

  /// No description provided for @subscriptionMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get subscriptionMonthly;

  /// No description provided for @subscriptionYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get subscriptionYearly;

  /// No description provided for @subscriptionNextLabel.
  ///
  /// In en, this message translates to:
  /// **'Next payment {date}'**
  String subscriptionNextLabel(String date);

  /// No description provided for @subscriptionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No subscriptions yet. Add streaming, apps or memberships.'**
  String get subscriptionsEmpty;

  /// No description provided for @subscriptionsMonthly.
  ///
  /// In en, this message translates to:
  /// **'{amount} a month in subscriptions'**
  String subscriptionsMonthly(String amount);

  /// No description provided for @subscriptionPayHint.
  ///
  /// In en, this message translates to:
  /// **'Records this payment in Budget under {category} and moves the date to the next one.'**
  String subscriptionPayHint(String category);

  /// No description provided for @choresModule.
  ///
  /// In en, this message translates to:
  /// **'Chores'**
  String get choresModule;

  /// No description provided for @choresTileLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 chore left today} other{{count} chores left today}}'**
  String choresTileLeft(int count);

  /// No description provided for @choresTileMine.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 is yours today} other{{count} are yours today}}'**
  String choresTileMine(int count);

  /// No description provided for @choresTileDone.
  ///
  /// In en, this message translates to:
  /// **'All done today'**
  String get choresTileDone;

  /// No description provided for @choresTileNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing today'**
  String get choresTileNone;

  /// No description provided for @choresLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 left today} other{{count} left today}}'**
  String choresLeft(int count);

  /// No description provided for @choresAllDone.
  ///
  /// In en, this message translates to:
  /// **'All done today'**
  String get choresAllDone;

  /// No description provided for @choresNoneToday.
  ///
  /// In en, this message translates to:
  /// **'Nothing today'**
  String get choresNoneToday;

  /// No description provided for @choresDoneCaption.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Tick a chore when it\'s done.} =1{1 done so far. Salamat!} other{{count} done so far. Salamat!}}'**
  String choresDoneCaption(int count);

  /// No description provided for @choresMineCaption.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 of them is yours.} other{{count} of them are yours.}}'**
  String choresMineCaption(int count);

  /// No description provided for @choresToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get choresToday;

  /// No description provided for @choresComingUp.
  ///
  /// In en, this message translates to:
  /// **'Coming up'**
  String get choresComingUp;

  /// No description provided for @choresEmpty.
  ///
  /// In en, this message translates to:
  /// **'No chores for today.'**
  String get choresEmpty;

  /// No description provided for @choresEmptyAdult.
  ///
  /// In en, this message translates to:
  /// **'No chores yet. Add dishes, laundry, sweeping or taking out the trash.'**
  String get choresEmptyAdult;

  /// No description provided for @choreAdd.
  ///
  /// In en, this message translates to:
  /// **'Add chore'**
  String get choreAdd;

  /// No description provided for @choreEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit chore'**
  String get choreEdit;

  /// No description provided for @choreRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove chore'**
  String get choreRemove;

  /// No description provided for @choreNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Wash the dishes'**
  String get choreNameHint;

  /// No description provided for @choreWho.
  ///
  /// In en, this message translates to:
  /// **'Who does it'**
  String get choreWho;

  /// No description provided for @choreAnyone.
  ///
  /// In en, this message translates to:
  /// **'Anyone'**
  String get choreAnyone;

  /// No description provided for @choreDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get choreDaily;

  /// No description provided for @choreWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get choreWeekly;

  /// No description provided for @choreOnce.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get choreOnce;

  /// No description provided for @choreEveryWeekday.
  ///
  /// In en, this message translates to:
  /// **'Every {day}'**
  String choreEveryWeekday(String day);

  /// No description provided for @choreOnceOn.
  ///
  /// In en, this message translates to:
  /// **'Once, {date}'**
  String choreOnceOn(String date);

  /// No description provided for @choreDoneBy.
  ///
  /// In en, this message translates to:
  /// **'Done by {names}'**
  String choreDoneBy(String names);

  /// No description provided for @choreOverdueSince.
  ///
  /// In en, this message translates to:
  /// **'Not done since {date}'**
  String choreOverdueSince(String date);

  /// No description provided for @choreMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get choreMarkDone;

  /// No description provided for @choreUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get choreUndo;

  /// No description provided for @choreUndoOnlyDoer.
  ///
  /// In en, this message translates to:
  /// **'Only the person who did it can undo it.'**
  String get choreUndoOnlyDoer;

  /// No description provided for @calendarModule.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarModule;

  /// No description provided for @calendarTileToday.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 thing today} other{{count} things today}}'**
  String calendarTileToday(int count);

  /// No description provided for @calendarTileNext.
  ///
  /// In en, this message translates to:
  /// **'Next: {title}, {when}'**
  String calendarTileNext(String title, String when);

  /// No description provided for @calendarTileNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing coming up'**
  String get calendarTileNone;

  /// No description provided for @calendarFreeToday.
  ///
  /// In en, this message translates to:
  /// **'Free today'**
  String get calendarFreeToday;

  /// No description provided for @calendarCountToday.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 today} other{{count} today}}'**
  String calendarCountToday(int count);

  /// No description provided for @calendarNext.
  ///
  /// In en, this message translates to:
  /// **'Next: {title}, {when}'**
  String calendarNext(String title, String when);

  /// No description provided for @calendarNothingAhead.
  ///
  /// In en, this message translates to:
  /// **'Nothing in the next 30 days'**
  String get calendarNothingAhead;

  /// No description provided for @calendarToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get calendarToday;

  /// No description provided for @calendarTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get calendarTomorrow;

  /// No description provided for @calendarDayEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing on this day.'**
  String get calendarDayEmpty;

  /// No description provided for @calendarComingUp.
  ///
  /// In en, this message translates to:
  /// **'Coming up'**
  String get calendarComingUp;

  /// No description provided for @calendarPrevMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get calendarPrevMonth;

  /// No description provided for @calendarNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get calendarNextMonth;

  /// No description provided for @calendarBillDue.
  ///
  /// In en, this message translates to:
  /// **'Bill due'**
  String get calendarBillDue;

  /// No description provided for @calendarSubscriptionDue.
  ///
  /// In en, this message translates to:
  /// **'Subscription due'**
  String get calendarSubscriptionDue;

  /// No description provided for @eventAdd.
  ///
  /// In en, this message translates to:
  /// **'Add event'**
  String get eventAdd;

  /// No description provided for @eventEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit event'**
  String get eventEdit;

  /// No description provided for @eventRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove event'**
  String get eventRemove;

  /// No description provided for @eventTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get eventTitle;

  /// No description provided for @eventTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Dentist, Lola\'s birthday'**
  String get eventTitleHint;

  /// No description provided for @eventTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a title.'**
  String get eventTitleRequired;

  /// No description provided for @eventAllDay.
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get eventAllDay;

  /// No description provided for @eventEndTime.
  ///
  /// In en, this message translates to:
  /// **'End time'**
  String get eventEndTime;

  /// No description provided for @eventOnce.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get eventOnce;

  /// No description provided for @eventWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get eventWeekly;

  /// No description provided for @eventMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get eventMonthly;

  /// No description provided for @eventYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get eventYearly;

  /// No description provided for @eventForWho.
  ///
  /// In en, this message translates to:
  /// **'Who it\'s for'**
  String get eventForWho;

  /// No description provided for @eventEveryone.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get eventEveryone;

  /// No description provided for @eventLocation.
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get eventLocation;

  /// No description provided for @eventNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get eventNote;

  /// No description provided for @eventAddedBy.
  ///
  /// In en, this message translates to:
  /// **'Added by {name}'**
  String eventAddedBy(String name);

  /// No description provided for @versionLine.
  ///
  /// In en, this message translates to:
  /// **'Version {app} · hub {hub}'**
  String versionLine(String app, String hub);

  /// No description provided for @versionLineNoHub.
  ///
  /// In en, this message translates to:
  /// **'Version {app}'**
  String versionLineNoHub(String app);

  /// No description provided for @catDebt.
  ///
  /// In en, this message translates to:
  /// **'Debt payments'**
  String get catDebt;

  /// No description provided for @debtsModule.
  ///
  /// In en, this message translates to:
  /// **'Debts & loans'**
  String get debtsModule;

  /// No description provided for @debtsTileOwed.
  ///
  /// In en, this message translates to:
  /// **'{amount} owed'**
  String debtsTileOwed(String amount);

  /// No description provided for @debtsTileOverdue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 payment overdue} other{{count} payments overdue}}'**
  String debtsTileOverdue(int count);

  /// No description provided for @debtsTileNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing owed'**
  String get debtsTileNone;

  /// No description provided for @debtsOwed.
  ///
  /// In en, this message translates to:
  /// **'{amount} owed'**
  String debtsOwed(String amount);

  /// No description provided for @debtsOwedToUs.
  ///
  /// In en, this message translates to:
  /// **'{amount} owed to you'**
  String debtsOwedToUs(String amount);

  /// No description provided for @debtsNone.
  ///
  /// In en, this message translates to:
  /// **'No debts'**
  String get debtsNone;

  /// No description provided for @debtsOverdueCaption.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 payment overdue. Pay it soon.} other{{count} payments overdue. Pay them soon.}}'**
  String debtsOverdueCaption(int count);

  /// No description provided for @debtsEmptyCaption.
  ///
  /// In en, this message translates to:
  /// **'Loans, cards, pawn tickets and money lent.'**
  String get debtsEmptyCaption;

  /// No description provided for @debtsYouOwe.
  ///
  /// In en, this message translates to:
  /// **'You owe'**
  String get debtsYouOwe;

  /// No description provided for @debtsOwedToYou.
  ///
  /// In en, this message translates to:
  /// **'Owed to you'**
  String get debtsOwedToYou;

  /// No description provided for @debtsPaidOff.
  ///
  /// In en, this message translates to:
  /// **'Paid off'**
  String get debtsPaidOff;

  /// No description provided for @debtsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet. Add a loan, credit card, pawn ticket or money you lent.'**
  String get debtsEmpty;

  /// No description provided for @debtAdd.
  ///
  /// In en, this message translates to:
  /// **'Add debt'**
  String get debtAdd;

  /// No description provided for @debtKind.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, loan{Loan} card{Credit card} pawn{Pawn ticket} other{Money lent}}'**
  String debtKind(String kind);

  /// No description provided for @debtNameHint.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, loan{e.g. Pag-IBIG salary loan} card{e.g. BPI card} pawn{e.g. Gold ring} other{e.g. Tito Ben}}'**
  String debtNameHint(String kind);

  /// No description provided for @debtCounterpartyLabel.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, loan{Lender (optional)} card{Bank (optional)} pawn{Pawnshop (optional)} other{Who borrowed it (optional)}}'**
  String debtCounterpartyLabel(String kind);

  /// No description provided for @debtReferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, pawn{Ticket number (optional)} card{Last 4 digits (optional)} other{Account or reference (optional)}}'**
  String debtReferenceLabel(String kind);

  /// No description provided for @debtPrincipalLabel.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, loan{Amount borrowed} card{Balance now} pawn{Amount received} other{Amount lent}}'**
  String debtPrincipalLabel(String kind);

  /// No description provided for @debtInstallmentLabel.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, card{Minimum due (optional)} other{Monthly payment (optional)}}'**
  String debtInstallmentLabel(String kind);

  /// No description provided for @debtDueLabel.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, pawn{Maturity: {date}} other{Next due: {date}}}'**
  String debtDueLabel(String kind, String date);

  /// No description provided for @debtSetDue.
  ///
  /// In en, this message translates to:
  /// **'Set a due date'**
  String get debtSetDue;

  /// No description provided for @debtClearDue.
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get debtClearDue;

  /// No description provided for @debtRepeatMonthly.
  ///
  /// In en, this message translates to:
  /// **'Due every month'**
  String get debtRepeatMonthly;

  /// No description provided for @debtRepeatHelp.
  ///
  /// In en, this message translates to:
  /// **'Paying near the due date moves it to next month.'**
  String get debtRepeatHelp;

  /// No description provided for @debtNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get debtNote;

  /// No description provided for @debtBalanceLine.
  ///
  /// In en, this message translates to:
  /// **'{balance} left of {principal}'**
  String debtBalanceLine(String balance, String principal);

  /// No description provided for @debtInstallmentLine.
  ///
  /// In en, this message translates to:
  /// **'{amount} a month'**
  String debtInstallmentLine(String amount);

  /// No description provided for @debtPay.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, lent{Got paid back} other{Record payment}}'**
  String debtPay(String kind);

  /// No description provided for @debtAddCharge.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, lent{Lent more} card{Add charges} other{Add to balance}}'**
  String debtAddCharge(String kind);

  /// No description provided for @debtInterestOnly.
  ///
  /// In en, this message translates to:
  /// **'Interest only'**
  String get debtInterestOnly;

  /// No description provided for @debtInterestHelp.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, pawn{Renewing the ticket? Pay the interest only: the balance stays.} other{The balance stays the same.}}'**
  String debtInterestHelp(String kind);

  /// No description provided for @debtPayHint.
  ///
  /// In en, this message translates to:
  /// **'Recorded in Budget under Debt payments.'**
  String get debtPayHint;

  /// No description provided for @debtAmountPaid.
  ///
  /// In en, this message translates to:
  /// **'Amount paid'**
  String get debtAmountPaid;

  /// No description provided for @debtAmountAdded.
  ///
  /// In en, this message translates to:
  /// **'Amount added'**
  String get debtAmountAdded;

  /// No description provided for @debtClose.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, pawn{Mark redeemed} lent{Mark repaid} other{Mark paid off}}'**
  String debtClose(String kind);

  /// No description provided for @debtClosedOn.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, pawn{Redeemed {date}} lent{Repaid {date}} other{Paid off {date}}}'**
  String debtClosedOn(String kind, String date);

  /// No description provided for @debtReopen.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get debtReopen;

  /// No description provided for @debtReopenOnlyCloser.
  ///
  /// In en, this message translates to:
  /// **'Only the person who closed it can reopen it.'**
  String get debtReopenOnlyCloser;

  /// No description provided for @debtEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit debt'**
  String get debtEdit;

  /// No description provided for @debtRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove debt'**
  String get debtRemove;

  /// No description provided for @debtHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get debtHistory;

  /// No description provided for @debtHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing recorded yet.'**
  String get debtHistoryEmpty;

  /// No description provided for @debtEntry.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, payment{Payment} interest{Interest} other{Added}}'**
  String debtEntry(String kind);

  /// No description provided for @debtRemoveEntry.
  ///
  /// In en, this message translates to:
  /// **'Remove this entry'**
  String get debtRemoveEntry;
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
