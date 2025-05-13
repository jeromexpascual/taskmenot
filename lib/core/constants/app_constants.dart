// lib/core/constants/app_constants.dart
import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF7960FF);
  static const primaryLight = Color(0xFFC5BAFF);
  static const background = Color(0xFFFBFBFB);
  static const textDark = Color(0xFF2C2C2C);
  static const socialButtonText = Color(0xFF4280EF);
  static const textLight = Color(0xFFFBFBFB);
}

class AppTextStyles {
  static const String jakartaSans = 'PlusJakartaSans';

  static const TextStyle bodySmall = TextStyle(
    fontFamily: jakartaSans,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: jakartaSans,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: jakartaSans,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: jakartaSans,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle heading1 = TextStyle(
    fontFamily: jakartaSans,
    fontSize: 42,
    fontWeight: FontWeight.w700,
  );
}