import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimens.dart';
import '../../core/constants/typography.dart';

class EcoTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: EcoColors.primaryGreen,
        secondary: EcoColors.freshAccent,
        surface: EcoColors.surfaceWhite,
        error: EcoColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: EcoColors.textPrimary,
      ),
      scaffoldBackgroundColor: EcoColors.backgroundLight,
      textTheme: EcoTypography.getTextTheme(false),
      cardTheme: CardThemeData(
        color: EcoColors.surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(EcoRadius.medium),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: EcoColors.primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(EcoRadius.medium),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: EcoColors.primaryGreen,
            );
          }
          return const TextStyle(fontSize: 10, color: EcoColors.textSecondary);
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(size: 24, color: Colors.white);
          }
          return const IconThemeData(size: 24, color: EcoColors.textSecondary);
        }),
        indicatorColor: EcoColors.primaryGreen,
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: EcoColors.freshAccent,
        secondary: EcoColors.primaryGreen,
        surface: EcoColors.surfaceDark,
        error: EcoColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: EcoColors.textPrimaryDark,
      ),
      scaffoldBackgroundColor: EcoColors.backgroundDark,
      textTheme: EcoTypography.getTextTheme(true),
      cardTheme: CardThemeData(
        color: EcoColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(EcoRadius.medium),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: EcoColors.freshAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(EcoRadius.medium),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: EcoColors.freshAccent,
            );
          }
          return const TextStyle(
            fontSize: 10,
            color: EcoColors.textSecondaryDark,
          );
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(size: 24, color: Colors.white);
          }
          return const IconThemeData(
            size: 24,
            color: EcoColors.textSecondaryDark,
          );
        }),
        indicatorColor: EcoColors.freshAccent,
      ),
    );
  }
}
