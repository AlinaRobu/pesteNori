// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Peste Nori';

  @override
  String get welcome => 'Welcome';

  @override
  String get peaksConquered => 'Conquered\nPeaks';

  @override
  String get cabinsConquered => 'Conquered\nCabins';

  @override
  String get collectionsCompleted => 'Complete\ncollections';

  @override
  String get nextLevel => 'Next Level';

  @override
  String get signOut => 'Sign out';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get home => 'Home';

  @override
  String get map => 'Map';

  @override
  String get routes => 'Routes';

  @override
  String get collections => 'Collections';

  @override
  String get profile => 'Profile';

  @override
  String get connect => 'Connect';

  @override
  String get createAccount => 'Create account';

  @override
  String get createTheAccount => 'Create your account';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get accountExists => 'Already have an account';

  @override
  String get authentication => 'Authentication';

  @override
  String get fillAll => 'Please fill in all the fields';

  @override
  String get diffPasswords => 'The passwords do not match';

  @override
  String get passLengthReq => 'The password must contain at least 6 characters';

  @override
  String get emailAlreadyInUse => 'There is already an account with this email address';

  @override
  String get invalidEmail => 'The email address is not valid';

  @override
  String get weakPass => 'Password too weak';

  @override
  String get emailRegNotAllowed => 'Email registration is not enabled';

  @override
  String get unknownError => 'Something went wrong';

  @override
  String get login => 'Login';

  @override
  String get forgotPass => 'I forgot my password';

  @override
  String get noAccount => 'Don\'t have an account? Don\'t worry!';

  @override
  String get createOneHere => 'You can quickly create one here!';

  @override
  String get addEmailCode => 'Enter the code received via email to reset your password';

  @override
  String get code => 'Code';

  @override
  String get passReset => 'Password reset';

  @override
  String get sendAgain => 'Resend the code via email';

  @override
  String get passWasReset => 'Password Reset!';

  @override
  String get emailSent => 'A password reset link has been sent to the email address.';

  @override
  String get titleStart => 'Collect experiences. \nDiscover the mountains.';

  @override
  String get or => 'OR';

  @override
  String get contin => 'Continue';

  @override
  String get continueWith => 'Continue with';

  @override
  String continueWithProvider(String provider) {
    return 'Continue with $provider';
  }

  @override
  String get loginFailed => 'Login failed';

  @override
  String get welcomeTo => 'Welcome to the community';

  @override
  String get createProfileFor => 'Create your profile to \ndiscover people and memories.';

  @override
  String get firstName => 'First name';

  @override
  String get addFirstName => 'Enter your first name';

  @override
  String get name => 'Name';

  @override
  String get addName => 'Enter your name';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get selectDateOfBirth => 'Select your date of birth';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get showBirthdayBadge => 'Show anniversary badge.';

  @override
  String get emptyFirstName => 'The first name is not filled in!';

  @override
  String get emptyName => 'The name is not filled in!';

  @override
  String get emptyDateOfBirth => 'Date of birth is not filled in!';

  @override
  String get emptySex => 'Sex is not filled in.';

  @override
  String get deleteAccountConfirm => 'This permanently deletes your account. You may need to sign in again first.';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteAccountError => 'Could not delete your account. Please try again.';

  @override
  String get confirmYourPassword => 'Confirm your password';

  @override
  String get confirm => 'Confirm';

  @override
  String get settings => 'Settings';

  @override
  String get loadingUserDataError => 'Error loading user data';

  @override
  String get signOutError => 'Error signing out';

  @override
  String get wrongPassword => 'Wrong password!';

  @override
  String get gallery => 'Gallery';

  @override
  String get selImageError => 'Error selecting image';

  @override
  String get saveProfileImageError => 'Profile image saving failed';

  @override
  String get loadingMap => 'Loading map…';

  @override
  String get mapStyleLoaded => 'Map style loaded';

  @override
  String get mapStyleError => 'Could not load the map style';

  @override
  String get loadingHikingTrails => 'Loading hiking routes and symbols…';

  @override
  String get tapTrailSymbol => 'Tap a hiking trail symbol';

  @override
  String get routeLoadingFailed => 'Could not load hiking trails';

  @override
  String get trailsStillLoading => 'Hiking trails are still loading. Try again shortly.';

  @override
  String get selectedTrailError => 'Could not show the selected trail';

  @override
  String get startingGps => 'Starting GPS…';

  @override
  String get stopNavigation => 'Stop navigation';

  @override
  String get followTrail => 'Follow this trail';

  @override
  String get offlineAvailability => 'Offline downloads are available on Android and iOS.';

  @override
  String get savedAreaOpenError => 'Could not show the saved map area.';

  @override
  String get smallerOfflineArea => 'Zoom in to download a smaller area.';

  @override
  String get mapAreaDownloaded => 'Map area downloaded.';

  @override
  String get offlineDownloadError => 'Offline download failed. Check your connection and try again.';

  @override
  String get chooseOfflineArea => 'Choose an offline area';

  @override
  String get frameOfflineArea => 'Pan and zoom to frame the area you want to save.';

  @override
  String get downloadArea => 'Download area';

  @override
  String get startingGpsTracking => 'Starting GPS tracking…';

  @override
  String get gpsError => 'GPS error';

  @override
  String get navigationStartError => 'Could not start navigation';

  @override
  String get hikeSaveError => 'Could not save this hike to your history.';

  @override
  String get hikeEndSaveError => 'Could not save the hike end time.';

  @override
  String get navigationStopped => 'Navigation stopped';

  @override
  String get trailNavigation => 'Trail navigation';

  @override
  String get findingWalkingDirections => 'Finding walking directions…';

  @override
  String get walkingDirectionsUnavailable => 'Walking directions unavailable';

  @override
  String get retry => 'Retry';

  @override
  String get waitingForAccurateGps => 'Waiting for a more accurate GPS fix…';

  @override
  String get waitingForGps => 'Waiting for GPS…';

  @override
  String get offTrailWarning => 'Warning: You may be off the trail';

  @override
  String get followGps => 'Follow GPS';

  @override
  String get showTrail => 'Show trail';

  @override
  String get myLocation => 'My location';

  @override
  String get resetMapNorth => 'Reset map to north';

  @override
  String get hikingMapTitle => 'Romania Hiking Map';

  @override
  String get searchTrails => 'Search trails';

  @override
  String get savedOfflineMaps => 'Saved offline maps';

  @override
  String get downloadingOfflineMap => 'Downloading offline map';

  @override
  String get findingLocation => 'Finding your location…';

  @override
  String get locationServicesRequired => 'Enable location services on your phone.';

  @override
  String get locationPermissionRequired => 'Location permission is required.';

  @override
  String get invalidTrailGeometry => 'The selected trail has no usable geometry.';

  @override
  String get renameOfflineMap => 'Rename offline map';

  @override
  String get nameOfflineMap => 'Name your offline map';

  @override
  String get offlineMapTitle => 'Title';

  @override
  String get optionalOfflineMapTitle => 'Title (optional)';

  @override
  String get enterOfflineMapTitle => 'Enter a title';

  @override
  String get save => 'Save';

  @override
  String get download => 'Download';

  @override
  String get offlineRenameError => 'Could not rename this map. Try again.';

  @override
  String get downloadStatusUnavailable => 'Download status unavailable';

  @override
  String get readyOffline => 'Ready offline';

  @override
  String get downloadIncomplete => 'Download incomplete';

  @override
  String get deleteOfflineMapQuestion => 'Delete offline map?';

  @override
  String get delete => 'Delete';

  @override
  String get offlineDeleteError => 'Could not delete this map. Try again.';

  @override
  String get savedMapsLoadError => 'Could not load saved maps. Retry';

  @override
  String get noOfflineMaps => 'No offline maps saved yet';

  @override
  String get offlineMapOptions => 'Offline map options';

  @override
  String get rename => 'Rename';

  @override
  String get downloadNewArea => 'Download new area';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get trailSearchHint => 'Enter a trail name, place, or reference';

  @override
  String get noMatchingTrails => 'No matching trails';

  @override
  String get weatherNotes => 'Weather notes';

  @override
  String get weatherConditions => 'Conditions';

  @override
  String get weatherUnspecified => 'Unspecified';

  @override
  String get weatherSunny => 'Sunny';

  @override
  String get weatherCloudy => 'Cloudy';

  @override
  String get weatherRain => 'Rain';

  @override
  String get weatherSnow => 'Snow';

  @override
  String get weatherFog => 'Fog';

  @override
  String get weatherMixed => 'Mixed';

  @override
  String get temperatureCelsius => 'Temperature (°C)';

  @override
  String get temperatureRange => 'Enter a temperature from -90 to 65';

  @override
  String get weatherSaveError => 'Could not save weather notes.';

  @override
  String get hikeHistory => 'Hike history';

  @override
  String get hikeHistoryLoadError => 'Could not load hike history';

  @override
  String get hikeHistoryEmpty => 'Start a trail on the Map to see it here.';

  @override
  String get hikeEndNotRecorded => 'End time not recorded';

  @override
  String get editWeatherNotes => 'Edit weather notes';

  @override
  String get unnamedTrail => 'Unnamed trail';

  @override
  String get camera => 'Camera';

  @override
  String get ok => 'OK';

  @override
  String get email => 'Email';

  @override
  String get resetPasswordInstructions => 'Enter your email address to reset your password.';

  @override
  String get sendEmail => 'Send email';

  @override
  String get birthDateFormat => 'DD / MM / YYYY';

  @override
  String noTrailNear(String name) {
    return 'No marked hiking trail found near $name.';
  }

  @override
  String selectedTrail(String name) {
    return 'Selected: $name';
  }

  @override
  String nearLandmark(String name) {
    return 'Near $name';
  }

  @override
  String trailDestination(String name) {
    return 'Destination: $name';
  }

  @override
  String trailLength(String distance) {
    return 'Trail length: $distance km';
  }

  @override
  String trailDistanceOsm(String distance) {
    return 'OSM distance: $distance km';
  }

  @override
  String trailMarking(String symbol) {
    return 'Marking: $symbol';
  }

  @override
  String trailStart(String name) {
    return 'Start: $name';
  }

  @override
  String trailNetwork(String network) {
    return 'Network: $network';
  }

  @override
  String landmarkDistanceFromTrail(String name, String distance) {
    return 'Near $name · $distance m from the trail';
  }

  @override
  String followingTrail(String name) {
    return 'Following $name';
  }

  @override
  String distanceFromTrail(String distance) {
    return 'Distance from trail: $distance m';
  }

  @override
  String gpsAccuracy(String accuracy) {
    return 'GPS accuracy: ±$accuracy m';
  }

  @override
  String estimatedRemaining(String distance) {
    return 'Estimated remaining: $distance km';
  }

  @override
  String offlineAreaNumber(String id) {
    return 'Offline area $id';
  }

  @override
  String removeOfflineMap(String name) {
    return 'Remove “$name” from this device?';
  }

  @override
  String fileSizeMb(String size) {
    return '$size MB';
  }

  @override
  String fileSizeKb(String size) {
    return '$size KB';
  }

  @override
  String distanceKm(String distance) {
    return '$distance km';
  }

  @override
  String hikeStartedAt(String time) {
    return 'Started $time';
  }

  @override
  String hikeEndedAt(String time) {
    return 'Ended $time';
  }

  @override
  String hikeDuration(String hours, String minutes) {
    return 'Duration: $hours h $minutes min';
  }

  @override
  String temperatureValue(String temperature) {
    return '$temperature °C';
  }

  @override
  String resetLinkSentTo(String email) {
    return 'A password reset link was sent to $email.';
  }

  @override
  String get sexLabel => 'Sex';
}
