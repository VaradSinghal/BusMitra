import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:busmitra/utils/constants.dart';
import 'package:busmitra/widgets/custom_button.dart';
import 'package:busmitra/widgets/custom_textfield.dart';
import 'package:busmitra/services/auth_service.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({super.key});

  @override
  UserLoginScreenState createState() => UserLoginScreenState();
}

class UserLoginScreenState extends State<UserLoginScreen> 
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isSignUp = false;
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
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      // Clear controllers when switching modes
      if (!_isSignUp) {
        _nameController.clear();
      }
    });
  }

  void _authenticate() async {
    setState(() => _isLoading = true);

    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    if (_isSignUp && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      if (_isSignUp) {
        final String name = _nameController.text.trim();
        await authService.signUpWithEmailAndPassword(email, password, name);
      } else {
        await authService.signInWithEmailAndPassword(email, password);
      }

      // Update last login time
      await authService.updateLastLogin();

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppConstants.errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                        color: Colors.black.withOpacity(0.3),
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
                              decoration: BoxDecoration(
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
                            Text(
                              'BusMitra',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _isSignUp ? 'Create Your Account' : 'Track Your Bus in Real-Time',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppConstants.lightTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Auth Form with staggered animation
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
                              // Name field (only for signup)
                              if (_isSignUp)
                                CustomTextField(
                                  controller: _nameController,
                                  hintText: 'Full Name',
                                  prefixIcon: Icons.person,
                                  iconColor: AppConstants.primaryColor,
                                ),
                              
                              if (_isSignUp) const SizedBox(height: 15),

                              // Email field
                              CustomTextField(
                                controller: _emailController,
                                hintText: 'Email Address',
                                prefixIcon: Icons.email,
                                iconColor: AppConstants.primaryColor,
                                keyboardType: TextInputType.emailAddress,
                              ),

                              const SizedBox(height: 15),

                              // Password field
                              CustomTextField(
                                controller: _passwordController,
                                hintText: 'Password',
                                prefixIcon: Icons.lock,
                                obscureText: _obscurePassword,
                                iconColor: AppConstants.primaryColor,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                    color: AppConstants.primaryColor.withOpacity(0.6),
                                  ),
                                  onPressed: _togglePasswordVisibility,
                                ),
                              ),

                              const SizedBox(height: 15),

                              // Forgot Password (only for login)
                              if (!_isSignUp)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      // Navigate to forgot password screen
                                      // _showForgotPasswordDialog();
                                    },
                                    child: Text(
                                      'Forgot Password?',
                                      style: TextStyle(color: AppConstants.primaryColor),
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 20),

                              // Login/Signup Button
                              CustomButton(
                                text: _isSignUp ? 'Sign Up' : 'Login',
                                onPressed: _authenticate,
                                isLoading: _isLoading,
                                backgroundColor: AppConstants.primaryColor,
                                textColor: AppConstants.accentColor,
                              ),

                              const SizedBox(height: 20),

                              // Switch between login and signup
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _isSignUp 
                                        ? 'Already have an account?' 
                                        : 'Don\'t have an account?',
                                    style: TextStyle(
                                      color: AppConstants.lightTextColor,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _toggleAuthMode,
                                    child: Text(
                                      _isSignUp ? 'Login' : 'Sign Up',
                                      style: TextStyle(
                                        color: AppConstants.primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // Support Text
                              const Text(
                                'Need help? Contact Support',
                                style: TextStyle(color: AppConstants.lightTextColor),
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