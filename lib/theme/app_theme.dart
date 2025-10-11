import 'package:flutter/material.dart';

class AppTheme {
  // Apple-inspired color palette
  static const Color appleBlue = Color(0xFF007AFF);
  static const Color appleGreen = Color(0xFF34C759);
  static const Color appleOrange = Color(0xFFFF9500);
  static const Color appleRed = Color(0xFFFF3B30);
  static const Color applePurple = Color(0xFFAF52DE);
  static const Color applePink = Color(0xFFFF2D92);
  static const Color appleTeal = Color(0xFF5AC8FA);
  static const Color appleIndigo = Color(0xFF5856D6);

  // Neutral colors
  static const Color systemGray = Color(0xFF8E8E93);
  static const Color systemGray2 = Color(0xFFAEAEB2);
  static const Color systemGray3 = Color(0xFFC7C7CC);
  static const Color systemGray4 = Color(0xFFD1D1D6);
  static const Color systemGray5 = Color(0xFFE5E5EA);
  static const Color systemGray6 = Color(0xFFF2F2F7);

  // Background colors
  static const Color systemBackground = Color(0xFFFFFFFF);
  static const Color secondarySystemBackground = Color(0xFFF2F2F7);
  static const Color tertiarySystemBackground = Color(0xFFFFFFFF);

  // Text colors
  static const Color label = Color(0xFF000000);
  static const Color secondaryLabel = Color(0xFF3C3C43);
  static const Color tertiaryLabel = Color(0xFF3C3C43);
  static const Color quaternaryLabel = Color(0xFF2C2C2E);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: '-apple-system',
      colorScheme: const ColorScheme.light(
        primary: appleBlue,
        secondary: appleGreen,
        surface: systemBackground,
        background: secondarySystemBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: label,
        onBackground: label,
        error: appleRed,
        onError: Colors.white,
        outline: systemGray4,
        shadow: Color(0x1A000000),
      ),
      scaffoldBackgroundColor: secondarySystemBackground,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: systemBackground,
        foregroundColor: label,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: label,
          letterSpacing: -0.41,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: systemBackground,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: systemGray5, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: appleBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.41,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: appleBlue,
          side: const BorderSide(color: appleBlue, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.41,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: appleBlue,
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.41,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: systemGray6,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: appleBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: const TextStyle(
          color: systemGray2,
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.41,
        ),
        labelStyle: const TextStyle(
          color: systemGray2,
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.41,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return appleBlue;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: systemGray3, width: 2),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.white;
          }
          return Colors.white;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return appleGreen;
          }
          return systemGray4;
        }),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: systemBackground,
        selectedItemColor: appleBlue,
        unselectedItemColor: systemGray2,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.24,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.24,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w400,
          color: label,
          letterSpacing: 0.37,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          color: label,
          letterSpacing: 0.36,
        ),
        displaySmall: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: label,
          letterSpacing: 0.35,
        ),
        headlineLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: label,
          letterSpacing: 0.38,
        ),
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: label,
          letterSpacing: -0.24,
        ),
        headlineSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: label,
          letterSpacing: -0.24,
        ),
        titleLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: label,
          letterSpacing: -0.41,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: label,
          letterSpacing: -0.24,
        ),
        titleSmall: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: label,
          letterSpacing: -0.24,
        ),
        bodyLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: label,
          letterSpacing: -0.41,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: label,
          letterSpacing: -0.24,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: secondaryLabel,
          letterSpacing: -0.08,
        ),
        labelLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: label,
          letterSpacing: -0.41,
        ),
        labelMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: label,
          letterSpacing: -0.24,
        ),
        labelSmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: secondaryLabel,
          letterSpacing: -0.08,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: '-apple-system',
      colorScheme: const ColorScheme.dark(
        primary: appleBlue,
        secondary: appleGreen,
        surface: Color(0xFF1C1C1E),
        background: Color(0xFF000000),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
        error: appleRed,
        onError: Colors.white,
        outline: Color(0xFF38383A),
        shadow: Color(0x1A000000),
      ),
      scaffoldBackgroundColor: const Color(0xFF000000),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Color(0xFF1C1C1E),
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: -0.41,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF1C1C1E),
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF38383A), width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: appleBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.41,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: appleBlue,
          side: const BorderSide(color: appleBlue, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.41,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: appleBlue,
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.41,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1C1C1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF38383A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: appleBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF8E8E93),
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.41,
        ),
        labelStyle: const TextStyle(
          color: Color(0xFF8E8E93),
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.41,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return appleBlue;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: Color(0xFF8E8E93), width: 2),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.white;
          }
          return Colors.white;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return appleGreen;
          }
          return const Color(0xFF38383A);
        }),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1C1C1E),
        selectedItemColor: appleBlue,
        unselectedItemColor: Color(0xFF8E8E93),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.24,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.24,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w400,
          color: Colors.white,
          letterSpacing: 0.37,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          color: Colors.white,
          letterSpacing: 0.36,
        ),
        displaySmall: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: Colors.white,
          letterSpacing: 0.35,
        ),
        headlineLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.38,
        ),
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: -0.24,
        ),
        headlineSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: -0.24,
        ),
        titleLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: -0.41,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: -0.24,
        ),
        titleSmall: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: -0.24,
        ),
        bodyLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: Colors.white,
          letterSpacing: -0.41,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Colors.white,
          letterSpacing: -0.24,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: Color(0xFF8E8E93),
          letterSpacing: -0.08,
        ),
        labelLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: Colors.white,
          letterSpacing: -0.41,
        ),
        labelMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Colors.white,
          letterSpacing: -0.24,
        ),
        labelSmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: Color(0xFF8E8E93),
          letterSpacing: -0.08,
        ),
      ),
    );
  }
}
