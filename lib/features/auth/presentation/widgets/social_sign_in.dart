import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/auth_exceptions.dart';
import '../../app_auth_provider.dart';

class SocialSignInButton extends StatelessWidget {
  final String iconPath;
  final String text;

  const SocialSignInButton({
    super.key,
    required this.iconPath,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Image.asset(iconPath, height: 24, width: 24),
      label: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          color: Color(0xFF4280EF),
          fontWeight: FontWeight.w600,
          fontFamily: AppTextStyles.jakartaSans,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      // Update social_sign_in.dart
      onPressed: () async {
        try {
          final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
          await authProvider.signInWithGoogle();
          // Do nothing here – AuthWrapper will automatically redirect
        } on AuthException catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message)),
          );
        }
      },
    );
  }
}