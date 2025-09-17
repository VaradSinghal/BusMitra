// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'பஸ்மித்ரா';

  @override
  String get selectRoute => 'வழியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get login => 'உள்நுழைய';

  @override
  String get signup => 'பதிவு செய்';

  @override
  String get email => 'மின்னஞ்சல்';

  @override
  String get password => 'கடவுச்சொல்';

  @override
  String get fullName => 'முழு பெயர்';

  @override
  String get createAccount => 'கணக்கை உருவாக்கு';

  @override
  String get continueWithGoogle => 'Google உடன் தொடரவும்';

  @override
  String get forgotPassword => 'கடவுச்சொல்லை மறந்துவிட்டீர்களா?';

  @override
  String get needHelp => 'உதவி தேவையா? ஆதரவைத் தொடர்பு கொள்ளுங்கள்';

  @override
  String get noActiveRoutes => 'செயலில் உள்ள வழிகள் எதுவும் இல்லை';

  @override
  String get loadingActiveRoutes => 'செயலில் உள்ள வழிகளை ஏற்றுகிறது...';

  @override
  String get failedToLoadRoutes => 'வழிகளை ஏற்ற முடியவில்லை';

  @override
  String get searchRoutes => 'வழிகளைத் தேடுங்கள்...';

  @override
  String get activeBuses => 'செயலில் உள்ள பஸ்கள்';

  @override
  String get noActiveBuses => 'செயலில் உள்ள பஸ்கள் இல்லை';

  @override
  String get nearestStop => 'அருகிலுள்ள நிறுத்தம்';

  @override
  String get upcomingStops => 'வரவிருக்கும் நிறுத்தங்கள்';

  @override
  String get lastUpdate => 'கடைசி புதுப்பிப்பு';

  @override
  String get live => 'நேரடி';

  @override
  String get offline => 'ஆஃப்லைன்';

  @override
  String get logout => 'வெளியேறு';

  @override
  String get eta => 'எதிர்பார்த்த நேரம்';

  @override
  String get distance => 'தூரம்';

  @override
  String get time => 'நேரம்';

  @override
  String get stops => 'நிறுத்தங்கள்';

  @override
  String get km => 'கி.மீ';

  @override
  String get min => 'நிமிடம்';

  @override
  String get hr => 'மணி';

  @override
  String get m => 'மீ';

  @override
  String get loadingMap => 'வரைபடத்தை ஏற்றுகிறது...';

  @override
  String get connectionLost => 'இணைப்பு துண்டிக்கப்பட்டது';

  @override
  String updatedAgo(Object time) {
    return '$time முன்பு புதுப்பிக்கப்பட்டது';
  }

  @override
  String get seconds => 'வி';

  @override
  String get minutes => 'நி';

  @override
  String get hours => 'ம';

  @override
  String andMoreStops(Object count) {
    return '... மற்றும் $count நிறுத்தங்கள் மேலும்';
  }

  @override
  String get selectLanguage => 'மொழியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get chooseYourLanguage =>
      'உங்கள் விருப்பமான மொழியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get continueText => 'தொடரவும்';

  @override
  String get welcome => 'பஸ்மித்ராவுக்கு வரவேற்கிறோம்';

  @override
  String get selectYourRoute => 'உங்கள் வழியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get routeDetails => 'வழி விவரங்கள்';

  @override
  String get busDetails => 'பஸ் விவரங்கள்';

  @override
  String get currentLocation => 'தற்போதைய இடம்';

  @override
  String get refresh => 'புதுப்பிக்கவும்';

  @override
  String get back => 'திரும்பு';

  @override
  String get next => 'அடுத்து';

  @override
  String get previous => 'முந்தைய';

  @override
  String get close => 'மூடு';

  @override
  String get ok => 'சரி';

  @override
  String get cancel => 'ரத்து';

  @override
  String get retry => 'மீண்டும் முயற்சி';

  @override
  String get error => 'பிழை';

  @override
  String get success => 'வெற்றி';

  @override
  String get loading => 'ஏற்றுகிறது...';

  @override
  String get noData => 'தரவு இல்லை';

  @override
  String get tryAgain => 'மீண்டும் முயற்சி';

  @override
  String get networkError =>
      'நெட்வொர்க் பிழை. உங்கள் இணைப்பைச் சரிபார்க்கவும்.';

  @override
  String get unknownError => 'அறியப்படாத பிழை ஏற்பட்டது';

  @override
  String get permissionDenied => 'அனுமதி மறுக்கப்பட்டது';

  @override
  String get locationPermissionDenied =>
      'உங்கள் தற்போதைய இடத்தைக் காட்ட அனுமதி தேவை';

  @override
  String get enableLocation => 'இடத்தை இயக்கு';

  @override
  String get goToSettings => 'அமைப்புகளுக்குச் செல்லுங்கள்';

  @override
  String get routeLabel => 'வழி';

  @override
  String get toLabel => 'இல்';

  @override
  String get activeLabel => 'செயலில்';
}
