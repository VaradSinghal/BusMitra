import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_ta.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('pa'),
    Locale('ta'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'BusMitra'**
  String get appTitle;

  /// No description provided for @selectRoute.
  ///
  /// In en, this message translates to:
  /// **'Select Route'**
  String get selectRoute;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

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

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @needHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help? Contact Support'**
  String get needHelp;

  /// No description provided for @noActiveRoutes.
  ///
  /// In en, this message translates to:
  /// **'No active routes found'**
  String get noActiveRoutes;

  /// No description provided for @loadingActiveRoutes.
  ///
  /// In en, this message translates to:
  /// **'Loading active routes...'**
  String get loadingActiveRoutes;

  /// No description provided for @failedToLoadRoutes.
  ///
  /// In en, this message translates to:
  /// **'Failed to load active routes'**
  String get failedToLoadRoutes;

  /// No description provided for @searchRoutes.
  ///
  /// In en, this message translates to:
  /// **'Search routes...'**
  String get searchRoutes;

  /// No description provided for @activeBuses.
  ///
  /// In en, this message translates to:
  /// **'Active Buses'**
  String get activeBuses;

  /// No description provided for @noActiveBuses.
  ///
  /// In en, this message translates to:
  /// **'No active buses'**
  String get noActiveBuses;

  /// No description provided for @nearestStop.
  ///
  /// In en, this message translates to:
  /// **'Nearest Stop'**
  String get nearestStop;

  /// No description provided for @upcomingStops.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Stops'**
  String get upcomingStops;

  /// No description provided for @lastUpdate.
  ///
  /// In en, this message translates to:
  /// **'Last Update'**
  String get lastUpdate;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get live;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @eta.
  ///
  /// In en, this message translates to:
  /// **'ETA'**
  String get eta;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @stops.
  ///
  /// In en, this message translates to:
  /// **'stops'**
  String get stops;

  /// No description provided for @km.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get km;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get min;

  /// No description provided for @hr.
  ///
  /// In en, this message translates to:
  /// **'hr'**
  String get hr;

  /// No description provided for @m.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get m;

  /// No description provided for @loadingMap.
  ///
  /// In en, this message translates to:
  /// **'Loading map...'**
  String get loadingMap;

  /// No description provided for @connectionLost.
  ///
  /// In en, this message translates to:
  /// **'Connection lost'**
  String get connectionLost;

  /// No description provided for @updatedAgo.
  ///
  /// In en, this message translates to:
  /// **'Updated {time} ago'**
  String updatedAgo(Object time);

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get seconds;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get minutes;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get hours;

  /// No description provided for @andMoreStops.
  ///
  /// In en, this message translates to:
  /// **'... and {count} more stops'**
  String andMoreStops(Object count);

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @chooseYourLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get chooseYourLanguage;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to BusMitra'**
  String get welcome;

  /// No description provided for @selectYourRoute.
  ///
  /// In en, this message translates to:
  /// **'Select your route'**
  String get selectYourRoute;

  /// No description provided for @routeDetails.
  ///
  /// In en, this message translates to:
  /// **'Route Details'**
  String get routeDetails;

  /// No description provided for @busDetails.
  ///
  /// In en, this message translates to:
  /// **'Bus Details'**
  String get busDetails;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get networkError;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get unknownError;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get permissionDenied;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to show your current location'**
  String get locationPermissionDenied;

  /// No description provided for @enableLocation.
  ///
  /// In en, this message translates to:
  /// **'Enable Location'**
  String get enableLocation;

  /// No description provided for @goToSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings'**
  String get goToSettings;

  /// No description provided for @routeLabel.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get routeLabel;

  /// No description provided for @toLabel.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get toLabel;

  /// No description provided for @activeLabel.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get activeLabel;
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
      <String>['en', 'hi', 'pa', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'pa':
      return AppLocalizationsPa();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
