import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF1B15FF);
  static const Color primaryDarkBlue = Color(0xFF100D99);
  static const Color primaryGreen = Color(0xFF00BB13);
  static const Color accentGreen = Color(0xFF51C513);

  // Background Colors
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundGray = Color(0xFFF1F1F1);

  // Text Colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF535353);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Accent Colors
  static const Color starYellow = Color(0xFFFFE166);
  static const Color buttonBlue = Color(0xFF1B15FF);
  static const Color buttonRed = Color(0xFFC12F52);
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
