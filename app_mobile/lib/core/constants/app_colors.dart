import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF0000FF);
  static const Color primaryDarkBlue = Color(0xFF0000AA);
  static const Color primaryGreen = Color(0xFF00FF00);
  static const Color accentGreen = Color(0xFF32CD32);

  // Background Colors
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundGray = Color(0xFFF5F5F5);

  // Text Colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Accent Colors
  static const Color starYellow = Color(0xFFFFD700);
  static const Color buttonBlue = Color(0xFF0000FF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryBlue, primaryDarkBlue],
  );

  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGreen, accentGreen],
  );
}
