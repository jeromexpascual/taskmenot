import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double height;
  final Alignment alignment;

  const AppLogo({
    super.key,
    this.height = 80,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Image.asset(
        'assets/images/Logo.png',
        height: height,
        fit: BoxFit.contain,
      ),
    );
  }
}