import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ro.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ro')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Peste Nori'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @peaksConquered.
  ///
  /// In en, this message translates to:
  /// **'Conquered Peaks'**
  String get peaksConquered;

  /// No description provided for @cabinsConquered.
  ///
  /// In en, this message translates to:
  /// **'Conquered Cabins'**
  String get cabinsConquered;

  /// No description provided for @collectionsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Complete collections'**
  String get collectionsCompleted;

  /// No description provided for @nextLevel.
  ///
  /// In en, this message translates to:
  /// **'Next Level'**
  String get nextLevel;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @routes.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get routes;

  /// No description provided for @collections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get collections;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @createTheAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createTheAccount;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @accountExists.
  ///
  /// In en, this message translates to:
  /// **'Already have an account'**
  String get accountExists;

  /// No description provided for @authentication.
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get authentication;

  /// No description provided for @fillAll.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all the fields'**
  String get fillAll;

  /// No description provided for @diffPasswords.
  ///
  /// In en, this message translates to:
  /// **'Parolele nu coincid'**
  String get diffPasswords;

  /// No description provided for @passLengthReq.
  ///
  /// In en, this message translates to:
  /// **'The password must contain at least 6 characters'**
  String get passLengthReq;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'There is already an account with this email address'**
  String get emailAlreadyInUse;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'The email address is not valid'**
  String get invalidEmail;

  /// No description provided for @weakPass.
  ///
  /// In en, this message translates to:
  /// **'Password too weak'**
  String get weakPass;

  /// No description provided for @emailRegNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Email registration is not enabled'**
  String get emailRegNotAllowed;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'A apărut o eroare'**
  String get unknownError;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @forgotPass.
  ///
  /// In en, this message translates to:
  /// **'I forgot my password'**
  String get forgotPass;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Don\'t worry!'**
  String get noAccount;

  /// No description provided for @createOneHere.
  ///
  /// In en, this message translates to:
  /// **'You can quickly create one here!'**
  String get createOneHere;

  /// No description provided for @addEmailCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the code received via email to reset your password'**
  String get addEmailCode;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @passReset.
  ///
  /// In en, this message translates to:
  /// **'Password reset'**
  String get passReset;

  /// No description provided for @sendAgain.
  ///
  /// In en, this message translates to:
  /// **'Resend the code via email'**
  String get sendAgain;

  /// No description provided for @passWasReset.
  ///
  /// In en, this message translates to:
  /// **'Password Reset!'**
  String get passWasReset;

  /// No description provided for @emailSent.
  ///
  /// In en, this message translates to:
  /// **'A password reset link has been sent to the email address.'**
  String get emailSent;

  /// No description provided for @titleStart.
  ///
  /// In en, this message translates to:
  /// **'Collect experiences. \nDiscover the mountains.'**
  String get titleStart;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @contin.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get contin;

  /// No description provided for @continueWith.
  ///
  /// In en, this message translates to:
  /// **'Continue with'**
  String get continueWith;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @welcomeTo.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the community'**
  String get welcomeTo;

  /// No description provided for @createProfileFor.
  ///
  /// In en, this message translates to:
  /// **'Create your profile to \ndiscover people and memories.'**
  String get createProfileFor;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @addFirstName.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get addFirstName;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @addName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get addName;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @selectDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Select your date of birth'**
  String get selectDateOfBirth;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @showBirthdayBadge.
  ///
  /// In en, this message translates to:
  /// **'Show anniversary badge.'**
  String get showBirthdayBadge;

  /// No description provided for @emptyFirstName.
  ///
  /// In en, this message translates to:
  /// **'The first name is not filled in!'**
  String get emptyFirstName;

  /// No description provided for @emptyName.
  ///
  /// In en, this message translates to:
  /// **'The name is not filled in!'**
  String get emptyName;

  /// No description provided for @emptyDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth is not filled in!'**
  String get emptyDateOfBirth;

  /// No description provided for @emptySex.
  ///
  /// In en, this message translates to:
  /// **'Sex is not filled in.'**
  String get emptySex;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Aceasta îți șterge definitiv contul. S-ar putea să fie nevoie să te autentifici din nou mai întâi.'**
  String get deleteAccountConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deleteAccountError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete your account. Please try again.'**
  String get deleteAccountError;

  /// No description provided for @confirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmYourPassword;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @loadingUserDataError.
  ///
  /// In en, this message translates to:
  /// **'Error loading user data'**
  String get loadingUserDataError;

  /// No description provided for @signOutError.
  ///
  /// In en, this message translates to:
  /// **'Error signing out'**
  String get signOutError;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password!'**
  String get wrongPassword;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @selImageError.
  ///
  /// In en, this message translates to:
  /// **'Error selecting image'**
  String get selImageError;

  /// No description provided for @saveProfileImageError.
  ///
  /// In en, this message translates to:
  /// **'Profile image saving failed'**
  String get saveProfileImageError;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ro'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ro': return AppLocalizationsRo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
