// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Panjabi Punjabi (`pa`).
class AppLocalizationsPa extends AppLocalizations {
  AppLocalizationsPa([String locale = 'pa']) : super(locale);

  @override
  String get appTitle => 'ਬਸਮਿਤਰ';

  @override
  String get selectRoute => 'ਰੂਟ ਚੁਣੋ';

  @override
  String get login => 'ਲੌਗ ਇਨ';

  @override
  String get signup => 'ਸਾਈਨ ਅੱਪ';

  @override
  String get email => 'ਈਮੇਲ';

  @override
  String get password => 'ਪਾਸਵਰਡ';

  @override
  String get fullName => 'ਪੂਰਾ ਨਾਮ';

  @override
  String get createAccount => 'ਖਾਤਾ ਬਣਾਓ';

  @override
  String get continueWithGoogle => 'Google ਨਾਲ ਜਾਰੀ ਰੱਖੋ';

  @override
  String get forgotPassword => 'ਪਾਸਵਰਡ ਭੁੱਲ ਗਏ?';

  @override
  String get needHelp => 'ਮਦਦ ਚਾਹੀਦੀ? ਸਹਾਇਤਾ ਨਾਲ ਸੰਪਰਕ ਕਰੋ';

  @override
  String get noActiveRoutes => 'ਕੋਈ ਸਰਗਰਮ ਰੂਟ ਨਹੀਂ ਮਿਲੇ';

  @override
  String get loadingActiveRoutes => 'ਸਰਗਰਮ ਰੂਟ ਲੋਡ ਹੋ ਰਹੇ ਹਨ...';

  @override
  String get failedToLoadRoutes => 'ਰੂਟ ਲੋਡ ਕਰਨ ਵਿੱਚ ਅਸਫਲ';

  @override
  String get searchRoutes => 'ਰੂਟ ਖੋਜੋ...';

  @override
  String get activeBuses => 'ਸਰਗਰਮ ਬੱਸਾਂ';

  @override
  String get noActiveBuses => 'ਕੋਈ ਸਰਗਰਮ ਬੱਸ ਨਹੀਂ';

  @override
  String get nearestStop => 'ਨਜ਼ਦੀਕੀ ਸਟਾਪ';

  @override
  String get upcomingStops => 'ਆਉਣ ਵਾਲੇ ਸਟਾਪ';

  @override
  String get lastUpdate => 'ਆਖਰੀ ਅਪਡੇਟ';

  @override
  String get live => 'ਲਾਈਵ';

  @override
  String get offline => 'ਆਫਲਾਈਨ';

  @override
  String get logout => 'ਲੌਗ ਆਉਟ';

  @override
  String get eta => 'ਅਨੁਮਾਨਿਤ ਸਮਾਂ';

  @override
  String get distance => 'ਦੂਰੀ';

  @override
  String get time => 'ਸਮਾਂ';

  @override
  String get stops => 'ਸਟਾਪ';

  @override
  String get km => 'ਕਿਮੀ';

  @override
  String get min => 'ਮਿੰ';

  @override
  String get hr => 'ਘੰ';

  @override
  String get m => 'ਮੀ';

  @override
  String get loadingMap => 'ਨਕਸ਼ਾ ਲੋਡ ਹੋ ਰਿਹਾ ਹੈ...';

  @override
  String get connectionLost => 'ਕਨੈਕਸ਼ਨ ਖੋ ਗਿਆ';

  @override
  String updatedAgo(Object time) {
    return '$time ਪਹਿਲਾਂ ਅਪਡੇਟ ਕੀਤਾ ਗਿਆ';
  }

  @override
  String get seconds => 'ਸੇ';

  @override
  String get minutes => 'ਮਿ';

  @override
  String get hours => 'ਘੰ';

  @override
  String andMoreStops(Object count) {
    return '... ਅਤੇ $count ਸਟਾਪ ਹੋਰ';
  }

  @override
  String get selectLanguage => 'ਭਾਸ਼ਾ ਚੁਣੋ';

  @override
  String get chooseYourLanguage => 'ਆਪਣੀ ਪਸੰਦੀਦਾ ਭਾਸ਼ਾ ਚੁਣੋ';

  @override
  String get continueText => 'ਜਾਰੀ ਰੱਖੋ';

  @override
  String get welcome => 'ਬਸਮਿਤਰ ਵਿੱਚ ਤੁਹਾਡਾ ਸਵਾਗਤ ਹੈ';

  @override
  String get selectYourRoute => 'ਆਪਣਾ ਰੂਟ ਚੁਣੋ';

  @override
  String get routeDetails => 'ਰੂਟ ਵਿਵਰਣ';

  @override
  String get busDetails => 'ਬੱਸ ਵਿਵਰਣ';

  @override
  String get currentLocation => 'ਮੌਜੂਦਾ ਸਥਾਨ';

  @override
  String get refresh => 'ਰਿਫਰੈਸ਼ ਕਰੋ';

  @override
  String get back => 'ਵਾਪਸ';

  @override
  String get next => 'ਅਗਲਾ';

  @override
  String get previous => 'ਪਿਛਲਾ';

  @override
  String get close => 'ਬੰਦ ਕਰੋ';

  @override
  String get ok => 'ਠੀਕ ਹੈ';

  @override
  String get cancel => 'ਰੱਦ ਕਰੋ';

  @override
  String get retry => 'ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼';

  @override
  String get error => 'ਗਲਤੀ';

  @override
  String get success => 'ਸਫਲਤਾ';

  @override
  String get loading => 'ਲੋਡ ਹੋ ਰਿਹਾ ਹੈ...';

  @override
  String get noData => 'ਕੋਈ ਡੇਟਾ ਉਪਲਬਧ ਨਹੀਂ';

  @override
  String get tryAgain => 'ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ';

  @override
  String get networkError => 'ਨੈੱਟਵਰਕ ਗਲਤੀ। ਕਿਰਪਾ ਕਰਕੇ ਆਪਣਾ ਕਨੈਕਸ਼ਨ ਜਾਂਚੋ।';

  @override
  String get unknownError => 'ਇੱਕ ਅਣਜਾਣ ਗਲਤੀ ਹੋਈ';

  @override
  String get permissionDenied => 'ਇਜਾਜ਼ਤ ਰੱਦ';

  @override
  String get locationPermissionDenied =>
      'ਤੁਹਾਡਾ ਮੌਜੂਦਾ ਸਥਾਨ ਦਿਖਾਉਣ ਲਈ ਇਜਾਜ਼ਤ ਚਾਹੀਦੀ ਹੈ';

  @override
  String get enableLocation => 'ਸਥਾਨ ਸਮਰੱਥ ਕਰੋ';

  @override
  String get goToSettings => 'ਸੈਟਿੰਗਾਂ \'ਤੇ ਜਾਓ';

  @override
  String get routeLabel => 'ਰੂਟ';

  @override
  String get toLabel => 'ਤੋਂ';

  @override
  String get activeLabel => 'ਸਰਗਰਮ';
}
