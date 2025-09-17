import 'package:busmitra/l10n/app_localizations.dart';
import 'package:busmitra/screens/language_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:busmitra/utils/constants.dart';
import 'package:busmitra/widgets/custom_button.dart';
import 'package:busmitra/widgets/custom_textfield.dart';
import 'package:busmitra/services/auth_service.dart';
import 'package:busmitra/services/language_service.dart';
import 'package:busmitra/screens/route_selection_screen.dart';
import 'package:busmitra/screens/signup_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() => _isLoading = true);

    final String driverIdOrEmail = _emailController.text.trim();
    final String password = _passwordController.text;

    if (driverIdOrEmail.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your credentials'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      await _authService.signInWithEmailAndPassword(driverIdOrEmail, password);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RouteSelectionScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithGoogle();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RouteSelectionScreen()),
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

  void _goToSignup() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SignupScreen()),
    );
  }

  Future<void> _logout() async {
    try {
      await AuthService().signOut();
      // Clear language preference on logout
      final languageService = Provider.of<LanguageService>(context, listen: false);
      await languageService.clearLanguage();
    } finally {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
          (route) => false,
        );
      }
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppConstants.primaryColor, AppConstants.secondaryColor],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                  ),
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: AppConstants.accentColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo and App Name with animation
                      ScaleTransition(
                        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: const BoxDecoration(
                                color: AppConstants.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.directions_bus,
                                size: 50,
                                color: AppConstants.accentColor,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Image.asset(
                              'assets/images/busMitra.png', 
                              height: 150, 
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Login Form with staggered animation
                      SizeTransition(
                        sizeFactor: CurvedAnimation(
                          parent: _animationController,
                          curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
                        ),
                        child: FadeTransition(
                          opacity: CurvedAnimation(
                            parent: _animationController,
                            curve: const Interval(0.4, 1.0),
                          ),
                          child: Column(
                            children: [
                              CustomTextField(
                                controller: _emailController,
                                hintText: l10n.email,
                                prefixIcon: Icons.email,
                                iconColor: AppConstants.primaryColor,
                                keyboardType: TextInputType.emailAddress,
                              ),

                              const SizedBox(height: 15),

                              CustomTextField(
                                controller: _passwordController,
                                hintText: l10n.password,
                                prefixIcon: Icons.lock,
                                obscureText: _obscurePassword,
                                iconColor: AppConstants.primaryColor,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                    color: AppConstants.primaryColor.withValues(alpha: 0.6),
                                  ),
                                  onPressed: _togglePasswordVisibility,
                                ),
                              ),

                              const SizedBox(height: 15),

                              // Forgot Password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    // Navigate to forgot password screen
                                  },
                                  child: Text(
                                    l10n.forgotPassword,
                                    style: const TextStyle(color: AppConstants.primaryColor),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Login Button
                              CustomButton(
                                text: l10n.login,
                                onPressed: _login,
                                isLoading: _isLoading,
                                backgroundColor: AppConstants.primaryColor,
                                textColor: AppConstants.accentColor,
                              ),

                              const SizedBox(height: 20),

                              // Or divider
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

                              const SizedBox(height: 20),

                              // Google Sign-In Button
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: _isLoading ? null : _loginWithGoogle,
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
                                      Text(l10n.continueWithGoogle),
                                    ],
                                  ),
                                ),
                              ),

                              // Signup redirect
                              TextButton(
                                onPressed: _goToSignup,
                                  child: Text(l10n.createAccount),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}  

