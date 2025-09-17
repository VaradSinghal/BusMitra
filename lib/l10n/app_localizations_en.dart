// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'BusMitra';

  @override
  String get selectRoute => 'Select Route';

  @override
  String get login => 'Login';

  @override
  String get signup => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get createAccount => 'Create Account';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get needHelp => 'Need help? Contact Support';

  @override
  String get noActiveRoutes => 'No active routes found';

  @override
  String get loadingActiveRoutes => 'Loading active routes...';

  @override
  String get failedToLoadRoutes => 'Failed to load active routes';

  @override
  String get searchRoutes => 'Search routes...';

  @override
  String get activeBuses => 'Active Buses';

  @override
  String get noActiveBuses => 'No active buses';

  @override
  String get nearestStop => 'Nearest Stop';

  @override
  String get upcomingStops => 'Upcoming Stops';

  @override
  String get lastUpdate => 'Last Update';

  @override
  String get live => 'Live';

  @override
  String get offline => 'Offline';

  @override
  String get logout => 'Logout';

  @override
  String get eta => 'ETA';

  @override
  String get distance => 'Distance';

  @override
  String get time => 'Time';

  @override
  String get stops => 'stops';

  @override
  String get km => 'km';

  @override
  String get min => 'min';

  @override
  String get hr => 'hr';

  @override
  String get m => 'm';

  @override
  String get loadingMap => 'Loading map...';

  @override
  String get connectionLost => 'Connection lost';

  @override
  String updatedAgo(Object time) {
    return 'Updated $time ago';
  }

  @override
  String get seconds => 's';

  @override
  String get minutes => 'm';

  @override
  String get hours => 'h';

  @override
  String andMoreStops(Object count) {
    return '... and $count more stops';
  }

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get chooseYourLanguage => 'Choose your preferred language';

  @override
  String get continueText => 'Continue';

  @override
  String get welcome => 'Welcome to BusMitra';

  @override
  String get selectYourRoute => 'Select your route';

  @override
  String get routeDetails => 'Route Details';

  @override
  String get busDetails => 'Bus Details';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get refresh => 'Refresh';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get retry => 'Retry';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get loading => 'Loading...';

  @override
  String get noData => 'No data available';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get networkError => 'Network error. Please check your connection.';

  @override
  String get unknownError => 'An unknown error occurred';

  @override
  String get permissionDenied => 'Permission denied';

  @override
  String get locationPermissionDenied =>
      'Location permission is required to show your current location';

  @override
  String get enableLocation => 'Enable Location';

  @override
  String get goToSettings => 'Go to Settings';

  @override
  String get routeLabel => 'Route';

  @override
  String get toLabel => 'to';

  @override
  String get activeLabel => 'ACTIVE';
}
