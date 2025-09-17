// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'बसमित्र';

  @override
  String get selectRoute => 'रूट चुनें';

  @override
  String get login => 'लॉग इन';

  @override
  String get signup => 'साइन अप';

  @override
  String get email => 'ईमेल';

  @override
  String get password => 'पासवर्ड';

  @override
  String get fullName => 'पूरा नाम';

  @override
  String get createAccount => 'खाता बनाएं';

  @override
  String get continueWithGoogle => 'Google के साथ जारी रखें';

  @override
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get needHelp => 'मदद चाहिए? सहायता से संपर्क करें';

  @override
  String get noActiveRoutes => 'कोई सक्रिय रूट नहीं मिले';

  @override
  String get loadingActiveRoutes => 'सक्रिय रूट लोड हो रहे हैं...';

  @override
  String get failedToLoadRoutes => 'रूट लोड करने में विफल';

  @override
  String get searchRoutes => 'रूट खोजें...';

  @override
  String get activeBuses => 'सक्रिय बसें';

  @override
  String get noActiveBuses => 'कोई सक्रिय बस नहीं';

  @override
  String get nearestStop => 'निकटतम स्टॉप';

  @override
  String get upcomingStops => 'आगामी स्टॉप';

  @override
  String get lastUpdate => 'अंतिम अपडेट';

  @override
  String get live => 'लाइव';

  @override
  String get offline => 'ऑफलाइन';

  @override
  String get logout => 'लॉग आउट';

  @override
  String get eta => 'अनुमानित समय';

  @override
  String get distance => 'दूरी';

  @override
  String get time => 'समय';

  @override
  String get stops => 'स्टॉप';

  @override
  String get km => 'किमी';

  @override
  String get min => 'मिन';

  @override
  String get hr => 'घं';

  @override
  String get m => 'मी';

  @override
  String get loadingMap => 'मैप लोड हो रहा है...';

  @override
  String get connectionLost => 'कनेक्शन खो गया';

  @override
  String updatedAgo(Object time) {
    return '$time पहले अपडेट किया गया';
  }

  @override
  String get seconds => 'से';

  @override
  String get minutes => 'मि';

  @override
  String get hours => 'घं';

  @override
  String andMoreStops(Object count) {
    return '... और $count स्टॉप और';
  }

  @override
  String get selectLanguage => 'भाषा चुनें';

  @override
  String get chooseYourLanguage => 'अपनी पसंदीदा भाषा चुनें';

  @override
  String get continueText => 'जारी रखें';

  @override
  String get welcome => 'बसमित्र में आपका स्वागत है';

  @override
  String get selectYourRoute => 'अपना रूट चुनें';

  @override
  String get routeDetails => 'रूट विवरण';

  @override
  String get busDetails => 'बस विवरण';

  @override
  String get currentLocation => 'वर्तमान स्थान';

  @override
  String get refresh => 'रिफ्रेश करें';

  @override
  String get back => 'वापस';

  @override
  String get next => 'अगला';

  @override
  String get previous => 'पिछला';

  @override
  String get close => 'बंद करें';

  @override
  String get ok => 'ठीक है';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get retry => 'पुनः प्रयास';

  @override
  String get error => 'त्रुटि';

  @override
  String get success => 'सफलता';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get noData => 'कोई डेटा उपलब्ध नहीं';

  @override
  String get tryAgain => 'पुनः प्रयास करें';

  @override
  String get networkError => 'नेटवर्क त्रुटि। कृपया अपना कनेक्शन जांचें।';

  @override
  String get unknownError => 'एक अज्ञात त्रुटि हुई';

  @override
  String get permissionDenied => 'अनुमति अस्वीकृत';

  @override
  String get locationPermissionDenied =>
      'आपका वर्तमान स्थान दिखाने के लिए अनुमति आवश्यक है';

  @override
  String get enableLocation => 'स्थान सक्षम करें';

  @override
  String get goToSettings => 'सेटिंग्स पर जाएं';

  @override
  String get routeLabel => 'रूट';

  @override
  String get toLabel => 'से';

  @override
  String get activeLabel => 'सक्रिय';
}
