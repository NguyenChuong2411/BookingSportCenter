import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: AppColors.backgroundWhite,
      fontFamily: 'OpenSans', // Font mặc định cho toàn bộ app

      textTheme: const TextTheme(
        // 1. Tiêu đề cần nhấn mạnh (ExtraBold)
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800, // Tương ứng OpenSans-ExtraBold
          color: AppColors.textPrimary,
        ),

        // 2. Tiêu đề thông thường (Bold)
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700, // Tương ứng OpenSans-Bold
          color: AppColors.textPrimary,
        ),

        // 3. Nội dung bình thường (Regular)
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400, // Tương ứng OpenSans-Regular
          color: AppColors.textPrimary,
        ),

        // 4. Các con số (Dùng font Oughter)
        displayLarge: TextStyle(
          fontFamily: 'Oughter',
          fontSize: 24,
          color: AppColors.primaryBlue,
        ),
      ),

      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlue,
        secondary: AppColors.primaryGreen,
        surface: AppColors.backgroundWhite,
        error: Colors.red,
        onPrimary: AppColors.textWhite,
        onSecondary: AppColors.textWhite,
        onSurface: AppColors.textPrimary,
      ),

      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppColors.textWhite),
        titleTextStyle: TextStyle(
          color: AppColors.textWhite,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonBlue,
          foregroundColor: AppColors.textWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),
    );
  }
}
