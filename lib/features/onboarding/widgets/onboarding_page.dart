// lib/features/onboarding/widgets/onboarding_page.dart
import 'package:flutter/material.dart';
import 'package:taskmenot/core/constants/app_constants.dart';

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final Color backgroundColor;

  const OnboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTextStyles.heading1.copyWith(
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Image.asset(
            image,
            height: 350,
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}