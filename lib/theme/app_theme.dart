import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2196F3); // blue
  static const Color secondary = Color(0xFFFF9800); // orange
  static const Color hint = Colors.grey;
  static const Color lightTextMain = Colors.black87;
  static const Color lightTextFaded = Colors.black54;
  static const Color darkTextMain = Colors.white;
  static const Color darkTextFaded = Colors.white70;
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
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.lightTextMain,
          ),
          bodyLarge: TextStyle(color: AppColors.lightTextMain),
          bodyMedium: TextStyle(color: AppColors.lightTextMain),
          bodySmall: TextStyle(color: AppColors.lightTextFaded),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
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
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.darkTextMain,
          ),
          bodyLarge: TextStyle(color: AppColors.darkTextMain),
          bodyMedium: TextStyle(color: AppColors.darkTextMain),
          bodySmall: TextStyle(color: AppColors.darkTextFaded),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      );
}
