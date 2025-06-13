import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2196F3); // blue
  static const Color secondary = Color(0xFFFF9800); // orange
  static const Color hint = Colors.grey;
}

class AppTextStyles {
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
}

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          titleLarge: AppTextStyles.sectionTitle,
        ),
        useMaterial3: true,
      );

  static ThemeData get darkTheme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          brightness: Brightness.dark,
        ),
        textTheme: const TextTheme(
          titleLarge: AppTextStyles.sectionTitle,
        ),
        useMaterial3: true,
      );
}
