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
  /// **'Conquered\nPeaks'**
  String get peaksConquered;

  /// No description provided for @cabinsConquered.
  ///
  /// In en, this message translates to:
  /// **'Conquered\nCabins'**
  String get cabinsConquered;

  /// No description provided for @collectionsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Complete\ncollections'**
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
  /// **'The passwords do not match'**
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
  /// **'Something went wrong'**
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

  /// No description provided for @continueWithProvider.
  ///
  /// In en, this message translates to:
  /// **'Continue with {provider}'**
  String continueWithProvider(String provider);

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
  /// **'This permanently deletes your account. You may need to sign in again first.'**
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

  /// No description provided for @loadingMap.
  ///
  /// In en, this message translates to:
  /// **'Loading map…'**
  String get loadingMap;

  /// No description provided for @mapStyleLoaded.
  ///
  /// In en, this message translates to:
  /// **'Map style loaded'**
  String get mapStyleLoaded;

  /// No description provided for @mapStyleError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the map style'**
  String get mapStyleError;

  /// No description provided for @loadingHikingTrails.
  ///
  /// In en, this message translates to:
  /// **'Loading hiking routes and symbols…'**
  String get loadingHikingTrails;

  /// No description provided for @tapTrailSymbol.
  ///
  /// In en, this message translates to:
  /// **'Tap a hiking trail symbol'**
  String get tapTrailSymbol;

  /// No description provided for @routeLoadingFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load hiking trails'**
  String get routeLoadingFailed;

  /// No description provided for @trailsStillLoading.
  ///
  /// In en, this message translates to:
  /// **'Hiking trails are still loading. Try again shortly.'**
  String get trailsStillLoading;

  /// No description provided for @selectedTrailError.
  ///
  /// In en, this message translates to:
  /// **'Could not show the selected trail'**
  String get selectedTrailError;

  /// No description provided for @startingGps.
  ///
  /// In en, this message translates to:
  /// **'Starting GPS…'**
  String get startingGps;

  /// No description provided for @stopNavigation.
  ///
  /// In en, this message translates to:
  /// **'Stop navigation'**
  String get stopNavigation;

  /// No description provided for @followTrail.
  ///
  /// In en, this message translates to:
  /// **'Follow this trail'**
  String get followTrail;

  /// No description provided for @offlineAvailability.
  ///
  /// In en, this message translates to:
  /// **'Offline downloads are available on Android and iOS.'**
  String get offlineAvailability;

  /// No description provided for @savedAreaOpenError.
  ///
  /// In en, this message translates to:
  /// **'Could not show the saved map area.'**
  String get savedAreaOpenError;

  /// No description provided for @smallerOfflineArea.
  ///
  /// In en, this message translates to:
  /// **'Zoom in to download a smaller area.'**
  String get smallerOfflineArea;

  /// No description provided for @mapAreaDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Map area downloaded.'**
  String get mapAreaDownloaded;

  /// No description provided for @offlineDownloadError.
  ///
  /// In en, this message translates to:
  /// **'Offline download failed. Check your connection and try again.'**
  String get offlineDownloadError;

  /// No description provided for @chooseOfflineArea.
  ///
  /// In en, this message translates to:
  /// **'Choose an offline area'**
  String get chooseOfflineArea;

  /// No description provided for @frameOfflineArea.
  ///
  /// In en, this message translates to:
  /// **'Pan and zoom to frame the area you want to save.'**
  String get frameOfflineArea;

  /// No description provided for @downloadArea.
  ///
  /// In en, this message translates to:
  /// **'Download area'**
  String get downloadArea;

  /// No description provided for @startingGpsTracking.
  ///
  /// In en, this message translates to:
  /// **'Starting GPS tracking…'**
  String get startingGpsTracking;

  /// No description provided for @gpsError.
  ///
  /// In en, this message translates to:
  /// **'GPS error'**
  String get gpsError;

  /// No description provided for @navigationStartError.
  ///
  /// In en, this message translates to:
  /// **'Could not start navigation'**
  String get navigationStartError;

  /// No description provided for @hikeSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save this hike to your history.'**
  String get hikeSaveError;

  /// No description provided for @hikeEndSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save the hike end time.'**
  String get hikeEndSaveError;

  /// No description provided for @navigationStopped.
  ///
  /// In en, this message translates to:
  /// **'Navigation stopped'**
  String get navigationStopped;

  /// No description provided for @trailNavigation.
  ///
  /// In en, this message translates to:
  /// **'Trail navigation'**
  String get trailNavigation;

  /// No description provided for @findingWalkingDirections.
  ///
  /// In en, this message translates to:
  /// **'Finding walking directions…'**
  String get findingWalkingDirections;

  /// No description provided for @walkingDirectionsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Walking directions unavailable'**
  String get walkingDirectionsUnavailable;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @waitingForAccurateGps.
  ///
  /// In en, this message translates to:
  /// **'Waiting for a more accurate GPS fix…'**
  String get waitingForAccurateGps;

  /// No description provided for @waitingForGps.
  ///
  /// In en, this message translates to:
  /// **'Waiting for GPS…'**
  String get waitingForGps;

  /// No description provided for @offTrailWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: You may be off the trail'**
  String get offTrailWarning;

  /// No description provided for @followGps.
  ///
  /// In en, this message translates to:
  /// **'Follow GPS'**
  String get followGps;

  /// No description provided for @showTrail.
  ///
  /// In en, this message translates to:
  /// **'Show trail'**
  String get showTrail;

  /// No description provided for @myLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get myLocation;

  /// No description provided for @resetMapNorth.
  ///
  /// In en, this message translates to:
  /// **'Reset map to north'**
  String get resetMapNorth;

  /// No description provided for @hikingMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Romania Hiking Map'**
  String get hikingMapTitle;

  /// No description provided for @searchTrails.
  ///
  /// In en, this message translates to:
  /// **'Search trails'**
  String get searchTrails;

  /// No description provided for @savedOfflineMaps.
  ///
  /// In en, this message translates to:
  /// **'Saved offline maps'**
  String get savedOfflineMaps;

  /// No description provided for @downloadingOfflineMap.
  ///
  /// In en, this message translates to:
  /// **'Downloading offline map'**
  String get downloadingOfflineMap;

  /// No description provided for @findingLocation.
  ///
  /// In en, this message translates to:
  /// **'Finding your location…'**
  String get findingLocation;

  /// No description provided for @locationServicesRequired.
  ///
  /// In en, this message translates to:
  /// **'Enable location services on your phone.'**
  String get locationServicesRequired;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required.'**
  String get locationPermissionRequired;

  /// No description provided for @invalidTrailGeometry.
  ///
  /// In en, this message translates to:
  /// **'The selected trail has no usable geometry.'**
  String get invalidTrailGeometry;

  /// No description provided for @renameOfflineMap.
  ///
  /// In en, this message translates to:
  /// **'Rename offline map'**
  String get renameOfflineMap;

  /// No description provided for @nameOfflineMap.
  ///
  /// In en, this message translates to:
  /// **'Name your offline map'**
  String get nameOfflineMap;

  /// No description provided for @offlineMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get offlineMapTitle;

  /// No description provided for @optionalOfflineMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Title (optional)'**
  String get optionalOfflineMapTitle;

  /// No description provided for @enterOfflineMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a title'**
  String get enterOfflineMapTitle;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @offlineRenameError.
  ///
  /// In en, this message translates to:
  /// **'Could not rename this map. Try again.'**
  String get offlineRenameError;

  /// No description provided for @downloadStatusUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Download status unavailable'**
  String get downloadStatusUnavailable;

  /// No description provided for @readyOffline.
  ///
  /// In en, this message translates to:
  /// **'Ready offline'**
  String get readyOffline;

  /// No description provided for @downloadIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Download incomplete'**
  String get downloadIncomplete;

  /// No description provided for @deleteOfflineMapQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete offline map?'**
  String get deleteOfflineMapQuestion;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @offlineDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete this map. Try again.'**
  String get offlineDeleteError;

  /// No description provided for @savedMapsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load saved maps. Retry'**
  String get savedMapsLoadError;

  /// No description provided for @noOfflineMaps.
  ///
  /// In en, this message translates to:
  /// **'No offline maps saved yet'**
  String get noOfflineMaps;

  /// No description provided for @offlineMapOptions.
  ///
  /// In en, this message translates to:
  /// **'Offline map options'**
  String get offlineMapOptions;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @downloadNewArea.
  ///
  /// In en, this message translates to:
  /// **'Download new area'**
  String get downloadNewArea;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @trailSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a trail name, place, or reference'**
  String get trailSearchHint;

  /// No description provided for @noMatchingTrails.
  ///
  /// In en, this message translates to:
  /// **'No matching trails'**
  String get noMatchingTrails;

  /// No description provided for @weatherNotes.
  ///
  /// In en, this message translates to:
  /// **'Weather notes'**
  String get weatherNotes;

  /// No description provided for @weatherConditions.
  ///
  /// In en, this message translates to:
  /// **'Conditions'**
  String get weatherConditions;

  /// No description provided for @weatherUnspecified.
  ///
  /// In en, this message translates to:
  /// **'Unspecified'**
  String get weatherUnspecified;

  /// No description provided for @weatherSunny.
  ///
  /// In en, this message translates to:
  /// **'Sunny'**
  String get weatherSunny;

  /// No description provided for @weatherCloudy.
  ///
  /// In en, this message translates to:
  /// **'Cloudy'**
  String get weatherCloudy;

  /// No description provided for @weatherRain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get weatherRain;

  /// No description provided for @weatherSnow.
  ///
  /// In en, this message translates to:
  /// **'Snow'**
  String get weatherSnow;

  /// No description provided for @weatherFog.
  ///
  /// In en, this message translates to:
  /// **'Fog'**
  String get weatherFog;

  /// No description provided for @weatherMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get weatherMixed;

  /// No description provided for @temperatureCelsius.
  ///
  /// In en, this message translates to:
  /// **'Temperature (°C)'**
  String get temperatureCelsius;

  /// No description provided for @temperatureRange.
  ///
  /// In en, this message translates to:
  /// **'Enter a temperature from -90 to 65'**
  String get temperatureRange;

  /// No description provided for @weatherSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save weather notes.'**
  String get weatherSaveError;

  /// No description provided for @hikeHistory.
  ///
  /// In en, this message translates to:
  /// **'Hike history'**
  String get hikeHistory;

  /// No description provided for @hikeHistoryLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load hike history'**
  String get hikeHistoryLoadError;

  /// No description provided for @hikeHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Start a trail on the Map to see it here.'**
  String get hikeHistoryEmpty;

  /// No description provided for @hikeEndNotRecorded.
  ///
  /// In en, this message translates to:
  /// **'End time not recorded'**
  String get hikeEndNotRecorded;

  /// No description provided for @editWeatherNotes.
  ///
  /// In en, this message translates to:
  /// **'Edit weather notes'**
  String get editWeatherNotes;

  /// No description provided for @unnamedTrail.
  ///
  /// In en, this message translates to:
  /// **'Unnamed trail'**
  String get unnamedTrail;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @resetPasswordInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address to reset your password.'**
  String get resetPasswordInstructions;

  /// No description provided for @sendEmail.
  ///
  /// In en, this message translates to:
  /// **'Send email'**
  String get sendEmail;

  /// No description provided for @birthDateFormat.
  ///
  /// In en, this message translates to:
  /// **'DD / MM / YYYY'**
  String get birthDateFormat;

  /// No description provided for @noTrailNear.
  ///
  /// In en, this message translates to:
  /// **'No marked hiking trail found near {name}.'**
  String noTrailNear(String name);

  /// No description provided for @selectedTrail.
  ///
  /// In en, this message translates to:
  /// **'Selected: {name}'**
  String selectedTrail(String name);

  /// No description provided for @nearLandmark.
  ///
  /// In en, this message translates to:
  /// **'Near {name}'**
  String nearLandmark(String name);

  /// No description provided for @trailDestination.
  ///
  /// In en, this message translates to:
  /// **'Destination: {name}'**
  String trailDestination(String name);

  /// No description provided for @trailLength.
  ///
  /// In en, this message translates to:
  /// **'Trail length: {distance} km'**
  String trailLength(String distance);

  /// No description provided for @trailDistanceOsm.
  ///
  /// In en, this message translates to:
  /// **'OSM distance: {distance} km'**
  String trailDistanceOsm(String distance);

  /// No description provided for @trailMarking.
  ///
  /// In en, this message translates to:
  /// **'Marking: {symbol}'**
  String trailMarking(String symbol);

  /// No description provided for @trailStart.
  ///
  /// In en, this message translates to:
  /// **'Start: {name}'**
  String trailStart(String name);

  /// No description provided for @trailNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network: {network}'**
  String trailNetwork(String network);

  /// No description provided for @landmarkDistanceFromTrail.
  ///
  /// In en, this message translates to:
  /// **'Near {name} · {distance} m from the trail'**
  String landmarkDistanceFromTrail(String name, String distance);

  /// No description provided for @followingTrail.
  ///
  /// In en, this message translates to:
  /// **'Following {name}'**
  String followingTrail(String name);

  /// No description provided for @distanceFromTrail.
  ///
  /// In en, this message translates to:
  /// **'Distance from trail: {distance} m'**
  String distanceFromTrail(String distance);

  /// No description provided for @gpsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'GPS accuracy: ±{accuracy} m'**
  String gpsAccuracy(String accuracy);

  /// No description provided for @estimatedRemaining.
  ///
  /// In en, this message translates to:
  /// **'Estimated remaining: {distance} km'**
  String estimatedRemaining(String distance);

  /// No description provided for @offlineAreaNumber.
  ///
  /// In en, this message translates to:
  /// **'Offline area {id}'**
  String offlineAreaNumber(String id);

  /// No description provided for @removeOfflineMap.
  ///
  /// In en, this message translates to:
  /// **'Remove “{name}” from this device?'**
  String removeOfflineMap(String name);

  /// No description provided for @fileSizeMb.
  ///
  /// In en, this message translates to:
  /// **'{size} MB'**
  String fileSizeMb(String size);

  /// No description provided for @fileSizeKb.
  ///
  /// In en, this message translates to:
  /// **'{size} KB'**
  String fileSizeKb(String size);

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'{distance} km'**
  String distanceKm(String distance);

  /// No description provided for @hikeStartedAt.
  ///
  /// In en, this message translates to:
  /// **'Started {time}'**
  String hikeStartedAt(String time);

  /// No description provided for @hikeEndedAt.
  ///
  /// In en, this message translates to:
  /// **'Ended {time}'**
  String hikeEndedAt(String time);

  /// No description provided for @hikeDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration: {hours} h {minutes} min'**
  String hikeDuration(String hours, String minutes);

  /// No description provided for @temperatureValue.
  ///
  /// In en, this message translates to:
  /// **'{temperature} °C'**
  String temperatureValue(String temperature);

  /// No description provided for @resetLinkSentTo.
  ///
  /// In en, this message translates to:
  /// **'A password reset link was sent to {email}.'**
  String resetLinkSentTo(String email);

  /// No description provided for @sexLabel.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get sexLabel;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileRomanian.
  ///
  /// In en, this message translates to:
  /// **'Romanian'**
  String get profileRomanian;

  /// No description provided for @profileEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get profileEnglish;

  /// No description provided for @profileDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get profileDarkMode;

  /// No description provided for @profileOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get profileOn;

  /// No description provided for @profileOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get profileOff;

  /// No description provided for @profileNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profileBearAlert.
  ///
  /// In en, this message translates to:
  /// **'Bear sightings'**
  String get profileBearAlert;

  /// No description provided for @profileSevereWeather.
  ///
  /// In en, this message translates to:
  /// **'Severe weather'**
  String get profileSevereWeather;

  /// No description provided for @profileTrailClosure.
  ///
  /// In en, this message translates to:
  /// **'Trail closures'**
  String get profileTrailClosure;

  /// No description provided for @profileAccidents.
  ///
  /// In en, this message translates to:
  /// **'Accidents'**
  String get profileAccidents;

  /// No description provided for @profileNotificationInfo.
  ///
  /// In en, this message translates to:
  /// **'These preferences are saved on this device. Trail alerts are not available yet.'**
  String get profileNotificationInfo;

  /// No description provided for @profilePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy settings'**
  String get profilePrivacy;

  /// No description provided for @profileTrailVisibility.
  ///
  /// In en, this message translates to:
  /// **'Trail visibility'**
  String get profileTrailVisibility;

  /// No description provided for @profileVisibilityInfo.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device. Your location is currently private.'**
  String get profileVisibilityInfo;

  /// No description provided for @profileSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get profileSupport;

  /// No description provided for @profileSupportUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Support contact details are not available yet.'**
  String get profileSupportUnavailable;

  /// No description provided for @profileTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get profileTerms;

  /// No description provided for @profileTermsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions are not available yet.'**
  String get profileTermsUnavailable;

  /// No description provided for @profileSettingsSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save the setting. Please try again.'**
  String get profileSettingsSaveError;

  /// No description provided for @profileSettingsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your saved preferences.'**
  String get profileSettingsLoadError;
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
