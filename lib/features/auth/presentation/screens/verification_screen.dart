// lib/features/auth/presentation/screens/verification_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskmenot/features/auth/app_auth_provider.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool _isLoading = false;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _checkVerification();
  }

  Future<void> _checkVerification() async {
    setState(() => _isLoading = true);
    await Provider.of<AppAuthProvider>(context, listen: false).reloadUser();
    final verified = Provider.of<AppAuthProvider>(context, listen: false).isEmailVerified;
    setState(() {
      _isVerified = verified;
      _isLoading = false;
    });
    if (_isVerified) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          const Text(
          'Verify your email address',
          style: TextStyle(fontSize: 24),),
          const SizedBox(height: 20),
          const Text('We\'ve sent an email to your inbox'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _checkVerification,
            child: const Text('I\'ve verified my email'),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () async {
              setState(() => _isLoading = true);
              await Provider.of<AppAuthProvider>(context, listen: false)
                  .sendEmailVerification();
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Verification email resent!'),
                ),
              );
            },
            child: const Text('Resend verification email'),
          ),
          ],
        ),
      ),
    );
  }
}