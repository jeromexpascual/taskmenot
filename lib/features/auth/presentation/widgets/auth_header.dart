// lib/features/auth/presentation/widgets/auth_header.dart
import 'package:flutter/material.dart';
import 'package:taskmenot/core/constants/app_constants.dart';
import 'package:taskmenot/core/widgets/logo.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final double topPadding;
  final bool showLogo;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.topPadding = 100.0,
    this.showLogo = true, // Optional: control logo visibility

  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: topPadding),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.primaryLight,
                ),
              ),
            ),
            if (showLogo)
              const Padding(
                padding: EdgeInsets.only(left: 20), // Space between text and logo
                child: AppLogo(height: 75), // Adjust size as needed
              ),
          ],
        ),
        const SizedBox(height: 0),
        Text(
          subtitle,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}