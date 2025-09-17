import 'package:busmitra/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/language_selection_screen.dart';
import 'services/language_service.dart';
import 'utils/constants.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BusMitraUserApp());
}

class BusMitraUserApp extends StatelessWidget {
  const BusMitraUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageService()),
      ],
      child: Consumer<LanguageService>(
        builder: (context, languageService, child) {
          return MaterialApp(
            title: AppConstants.appName,
            locale: languageService.currentLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), // English
              Locale('ta', ''), // Tamil
              Locale('hi', ''), // Hindi
              Locale('pa', ''), // Punjabi
            ],
      theme: ThemeData(
        primaryColor: AppConstants.primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.primaryColor,
          primary: AppConstants.primaryColor,
          secondary: AppConstants.secondaryColor,
          surface: AppConstants.backgroundColor,
          error: AppConstants.errorColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: AppConstants.accentColor,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: AppConstants.accentColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppConstants.accentColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        fontFamily: 'Roboto',
      ),
            home: const AppInitializer(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final languageService = Provider.of<LanguageService>(context, listen: false);
    await languageService.initializeLanguage();
    
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return const LanguageSelectionScreen();
  }
}