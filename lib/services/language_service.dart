import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class LanguageService with ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  Locale _currentLocale = const Locale('en', '');
  
  Locale get currentLocale => _currentLocale;
  
  final Map<String, Locale> _supportedLocales = {
    'English': const Locale('en', ''),
    'தமிழ்': const Locale('ta', ''),
    'हिन्दी': const Locale('hi', ''),
    'ਪੰਜਾਬੀ': const Locale('pa', ''),
  };
  
  Map<String, Locale> get supportedLocales => _supportedLocales;
  
  Future<void> initializeLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);
    
    if (languageCode != null) {
      _currentLocale = Locale(languageCode, '');
    }
    notifyListeners();
  }
  
  Future<void> setLanguage(String languageName) async {
    if (_supportedLocales.containsKey(languageName)) {
      _currentLocale = _supportedLocales[languageName]!;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, _currentLocale.languageCode);
      notifyListeners();
    }
  }
  
  Future<void> clearLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_languageKey);
    _currentLocale = const Locale('en', '');
    notifyListeners();
  }
  
  String getLanguageName(Locale locale) {
    for (final entry in _supportedLocales.entries) {
      if (entry.value.languageCode == locale.languageCode) {
        return entry.key;
      }
    }
    return 'English';
  }
}
