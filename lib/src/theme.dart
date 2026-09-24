import 'package:flutter/material.dart';

class AppColors {
  static const teal = Color(0xFF0E7C6B);
  static const tealDark = Color(0xFF0B6A5B);
  static const tealSoft = Color(0xFFE7F6F2);
  static const navy = Color(0xFF1B2430);
  static const ink = Color(0xFF243040);
  static const muted = Color(0xFF6E7A86);
  static const line = Color(0xFFE6EBE8);
  static const page = Color(0xFFF5F7F6);
  static const card = Colors.white;
  static const orange = Color(0xFFE8922A);
  static const orangeBg = Color(0xFFFFF3E4);
  static const coral = Color(0xFFE15B4C);
  static const coralBg = Color(0xFFFDECEA);
  static const green = Color(0xFF2EAE6A);
  static const greenBg = Color(0xFFE7F8EF);
  static const blue = Color(0xFF3D7EFF);
  static const blueBg = Color(0xFFEAF1FF);
  static const mint = Color(0xFFE8F7F1);
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.page,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.teal,
        primary: AppColors.teal,
        surface: Colors.white,
      ),
      fontFamily: '.AppleSystemUIFont',
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.navy,
        displayColor: AppColors.navy,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.navy,
      ),
    );
  }
}
