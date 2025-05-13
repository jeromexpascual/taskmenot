// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskmenot/core/constants/app_constants.dart';
import 'package:taskmenot/core/widgets/custom_button.dart';
import 'package:taskmenot/core/widgets/custom_textfield.dart';
import 'package:taskmenot/features/auth/presentation/widgets/auth_header.dart';
import 'package:taskmenot/features/auth/presentation/widgets/social_sign_in.dart';
import 'package:taskmenot/features/auth/presentation/screens/register_screen.dart';

import '../../../../core/utils/auth_exceptions.dart';
import '../../app_auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 50),
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const AuthHeader(
                  title: 'Sign in',
                  subtitle: 'Please log in to your account',
                  topPadding: 0,
                ),

                // Email Field
                const Text(
                  'Email',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _emailController,
                  hintText: 'myemail@gmail.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),

                // Password Field
                const SizedBox(height: 20),
                const Text(
                  'Password',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _passwordController,
                  hintText: '........',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                // Forgot Password
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () async {
                      if (_emailController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter your email first')),
                        );
                        return;
                      }

                      try {
                        final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
                        await authProvider.sendPasswordResetEmail(_emailController.text.trim());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password reset email sent')),
                        );
                      } on AuthException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.message)),
                        );
                      }
                    },
                    child: Text(
                      'Forgot password?',
                      style: AppTextStyles.bodySmall.copyWith(color: Color(0xFF7CABFF),
                      ),
                    ),
                  ),
                ),

                // Sign In Button
                const SizedBox(height: 30),
                CustomButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
                        await authProvider.signInWithEmailAndPassword(
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                        );
                        // This will automatically redirect via AuthWrapper
                      } on AuthException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.message)),
                        );
                      }
                    }
                  },
                  text: 'Sign in',
                  backgroundColor: AppColors.primary,
                  textColor: Colors.white,
                ),

                // Google Sign In
                const SizedBox(height: 12),
                const SocialSignInButton(
                  iconPath: 'assets/images/google_logo.png',
                  text: 'Sign in with Google',
                ),

                // Register Prompt
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'New user? ',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textDark,
                            ),
                          ),
                          TextSpan(
                            text: 'Create new account',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}


