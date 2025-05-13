import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskmenot/core/constants/app_constants.dart';
import 'package:taskmenot/core/widgets/custom_button.dart';
import 'package:taskmenot/core/widgets/custom_textfield.dart';
import 'package:taskmenot/features/auth/presentation/widgets/auth_header.dart';
import 'package:taskmenot/features/auth/presentation/screens/login_screen.dart';
import '../../app_auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isChecked = false;
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
                  title: 'Sign Up',
                  subtitle: 'Please create a new account',
                  topPadding: 0,
                ),

                // Name Field
                const Text(
                  'Name',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _nameController,
                  hintText: 'Enter your full name',
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),

                // Email Field
                const SizedBox(height: 20),
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
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),

                // Password Field
                const SizedBox(height: 20),
                Text(
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

                // Terms Checkbox
                const SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                      value: _isChecked,
                      onChanged: (bool? value) {
                        if (value != null) {
                          setState(() => _isChecked = value);
                        }
                      },
                      checkColor: Colors.white,
                      activeColor: AppColors.primary,
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                     Expanded(
                      child: Text(
                        'I agree to the terms of use and privacy policy',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),

                // Sign Up Button
                const SizedBox(height: 30),
                // Update the onPressed handler in register_screen.dart
                // Update the register button
                CustomButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate() && _isChecked) {
                      try {
                        final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
                        final email = _emailController.text.trim();
                        final password = _passwordController.text.trim();
                        final name = _nameController.text.trim();

                        final user = await authProvider.signUpWithEmailAndPassword(
                          email: email,
                          password: password,
                          name: name, // make sure to include name here now!
                        );

                        if (user == null) {
                          throw Exception('User creation failed - no user returned');
                        }
                        // AuthWrapper will handle redirection automatically
                        Navigator.of(context).pushReplacementNamed('/auth-wrapper');

                      } on FirebaseAuthException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.message ?? 'Registration failed')),
                        );
                      } on FirebaseException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.message ?? 'Failed to create profile')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('An unexpected error occurred')),
                        );
                      }
                    } else if (!_isChecked) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please accept the terms and conditions')),
                      );
                    }
                  },
                  text: 'Sign up',
                  backgroundColor: AppColors.primary,
                  textColor: Colors.white,
                ),

                // Already have account prompt
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(),
                        ),
                      );
                    },
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Already have an account? ',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textDark,
                            ),
                          ),
                          TextSpan(
                            text: 'Log in',
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}