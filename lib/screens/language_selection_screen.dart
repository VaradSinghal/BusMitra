import 'package:busmitra/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:busmitra/services/language_service.dart';
import 'package:busmitra/screens/login_screen.dart';
import 'package:busmitra/utils/constants.dart';
import 'package:provider/provider.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _selectedLanguage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectLanguage ?? 'Select Language'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: AppConstants.accentColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.chooseYourLanguage ?? 'Choose your preferred language',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.textColor,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: languageService.supportedLocales.length,
                itemBuilder: (context, index) {
                  final languageEntry = languageService.supportedLocales.entries.elementAt(index);
                  final languageName = languageEntry.key;
                  final isSelected = _selectedLanguage == languageName;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      elevation: isSelected ? 4 : 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected 
                              ? AppConstants.primaryColor 
                              : AppConstants.lightTextColor.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          languageName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected 
                                ? AppConstants.primaryColor 
                                : AppConstants.textColor,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: AppConstants.primaryColor,
                                size: 24,
                              )
                            : const Icon(
                                Icons.radio_button_unchecked,
                                color: AppConstants.lightTextColor,
                                size: 24,
                              ),
                        onTap: () {
                          setState(() {
                            _selectedLanguage = languageName;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _selectedLanguage != null ? _continue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: AppConstants.accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  l10n.continueText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _continue() async {
    if (_selectedLanguage != null) {
      final languageService = Provider.of<LanguageService>(context, listen: false);
      await languageService.setLanguage(_selectedLanguage!);
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }
}
