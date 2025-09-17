import 'package:busmitra/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:busmitra/utils/constants.dart';
import 'package:busmitra/widgets/custom_textfield.dart';
import 'package:busmitra/widgets/custom_button.dart';
import 'package:busmitra/services/auth_service.dart';
import 'package:busmitra/screens/language_selection_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  Future<void> _signup() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signUpWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signup failed: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _signupWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithGoogle();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In failed: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createAccount),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: AppConstants.accentColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CustomTextField(
              controller: _nameController,
              hintText: l10n.fullName,
              prefixIcon: Icons.person,
              iconColor: AppConstants.primaryColor,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _emailController,
              hintText: l10n.email,
              prefixIcon: Icons.email,
              iconColor: AppConstants.primaryColor,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _passwordController,
              hintText: l10n.password,
              prefixIcon: Icons.lock,
              obscureText: true,
              iconColor: AppConstants.primaryColor,
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: l10n.signup,
              onPressed: () { if (_isLoading) return; _signup(); },
              isLoading: _isLoading,
              backgroundColor: AppConstants.primaryColor,
              textColor: AppConstants.accentColor,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Divider(color: AppConstants.lightTextColor.withValues(alpha: 0.3))),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('OR'),
                ),
                Expanded(child: Divider(color: AppConstants.lightTextColor.withValues(alpha: 0.3))),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isLoading ? null : () { _signupWithGoogle(); },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  foregroundColor: AppConstants.secondaryColor,
                  side: BorderSide(color: AppConstants.lightTextColor.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  backgroundColor: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/google_logo.png',
                      height: 18,
                      width: 18,
                      errorBuilder: (context, error, stack) => const Icon(Icons.login, size: 18),
                    ),
                    const SizedBox(width: 8),
                    const Text('Continue with Google'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
