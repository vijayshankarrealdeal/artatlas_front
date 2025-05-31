import 'package:flutter/material.dart';

class AppTheme {
  static const String _fontFamily = 'FuturaPT'; // Your chosen font family

  // --- Light Theme ---
  static final ThemeData lightTheme = ThemeData(
    fontFamily: _fontFamily,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.grey.shade100, // Light background
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue, // Your primary seed color
      brightness: Brightness.light,
      primary: Colors.blue.shade700,
      onPrimary: Colors.white,
      secondary: Colors.lightBlue.shade600,
      onSecondary: Colors.white,
      error: Colors.red.shade700,
      onError: Colors.white,
      background: Colors.grey.shade100, // Slightly off-white
      onBackground: Colors.black87, // Dark text on light background
      surface: Colors.white, // Card backgrounds, dialogs
      onSurface: Colors.black87,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue.shade700,
      foregroundColor: Colors.white, // Icon and title color
      elevation: 2.0,
    ),
    textTheme: _buildTextTheme(
      ThemeData.light().textTheme,
      Colors.black87,
      Colors.black,
    ),
    primaryTextTheme: _buildTextTheme(
      ThemeData.light().primaryTextTheme,
      Colors.white,
      Colors.white70,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.blue.shade700, width: 1.5),
      ),
      labelStyle: TextStyle(color: Colors.grey.shade700),
      hintStyle: TextStyle(color: Colors.grey.shade500),
      filled: true,
      fillColor: Colors.white.withOpacity(0.8),
      prefixIconColor: Colors.grey.shade600,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: _fontFamily,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.blue.shade700,
        textStyle: const TextStyle(fontFamily: _fontFamily),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey.shade300,
      labelStyle: TextStyle(color: Colors.black87, fontFamily: _fontFamily),
      secondaryLabelStyle: TextStyle(
        color: Colors.black87,
        fontFamily: _fontFamily,
      ),
      selectedColor: Colors.blue.shade200,
      secondarySelectedColor: Colors.blue.shade200,
      deleteIconColor: Colors.black54,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    ),
    dividerColor: Colors.grey.shade300,
    iconTheme: IconThemeData(color: Colors.grey.shade700),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: Colors.blue.shade100,
      iconTheme: MaterialStateProperty.resolveWith<IconThemeData?>((states) {
        if (states.contains(MaterialState.selected)) {
          return IconThemeData(color: Colors.blue.shade700);
        }
        return IconThemeData(color: Colors.grey.shade600);
      }),
      labelTextStyle: MaterialStateProperty.all(
        TextStyle(
          fontSize: 12,
          fontFamily: _fontFamily,
          color: Colors.grey.shade700,
        ),
      ),
    ),
  );

  // --- Dark Theme ---
  static final ThemeData darkTheme = ThemeData(
    fontFamily: _fontFamily,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black, // True black or very dark grey
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue, // Your primary seed color
      brightness: Brightness.dark,
      primary: Colors.blue.shade400, // Lighter blue for dark mode
      onPrimary: Colors.black, // Text on primary button
      secondary: Colors.lightBlueAccent.shade200, // Lighter accent
      onSecondary: Colors.black,
      error: Colors.redAccent.shade100,
      onError: Colors.black,
      background: Colors.grey.shade900, // Dark background
      onBackground: Colors.white70, // Light text on dark background
      surface: Colors.grey.shade800, // Card backgrounds, dialogs
      onSurface: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey.shade800,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: _buildTextTheme(
      ThemeData.dark().textTheme,
      Colors.white70,
      Colors.white,
    ),
    primaryTextTheme: _buildTextTheme(
      ThemeData.dark().primaryTextTheme,
      Colors.black,
      Colors.black87,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade600),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.blue.shade400, width: 1.5),
      ),
      labelStyle: TextStyle(color: Colors.grey.shade400),
      hintStyle: TextStyle(color: Colors.grey.shade500),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      prefixIconColor: Colors.grey.shade400,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade400,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: _fontFamily,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.lightBlueAccent.shade200,
        textStyle: const TextStyle(fontFamily: _fontFamily),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey.shade700,
      labelStyle: TextStyle(color: Colors.white70, fontFamily: _fontFamily),
      secondaryLabelStyle: TextStyle(
        color: Colors.white70,
        fontFamily: _fontFamily,
      ),
      selectedColor: Colors.blue.shade700,
      secondarySelectedColor: Colors.blue.shade700,
      deleteIconColor: Colors.white54,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    ),
    dividerColor: Colors.grey.shade700,
    iconTheme: IconThemeData(color: Colors.grey.shade400),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.grey.shade900,
      indicatorColor: Colors.blue.shade800,
      iconTheme: MaterialStateProperty.resolveWith<IconThemeData?>((states) {
        if (states.contains(MaterialState.selected)) {
          return IconThemeData(color: Colors.blue.shade300);
        }
        return IconThemeData(color: Colors.grey.shade400);
      }),
      labelTextStyle: MaterialStateProperty.all(
        TextStyle(
          fontSize: 12,
          fontFamily: _fontFamily,
          color: Colors.grey.shade500,
        ),
      ),
    ),
  );

  // Helper to build TextTheme with consistent font family
  static TextTheme _buildTextTheme(
    TextTheme base,
    Color bodyColor,
    Color displayColor,
  ) {
    return base
        .copyWith(
          displayLarge: base.displayLarge?.copyWith(
            fontFamily: _fontFamily,
            color: displayColor,
          ),
          displayMedium: base.displayMedium?.copyWith(
            fontFamily: _fontFamily,
            color: displayColor,
          ),
          displaySmall: base.displaySmall?.copyWith(
            fontFamily: _fontFamily,
            color: displayColor,
          ),
          headlineLarge: base.headlineLarge?.copyWith(
            fontFamily: _fontFamily,
            color: displayColor,
          ),
          headlineMedium: base.headlineMedium?.copyWith(
            fontFamily: _fontFamily,
            color: displayColor,
          ),
          headlineSmall: base.headlineSmall?.copyWith(
            fontFamily: _fontFamily,
            color: displayColor,
          ),
          titleLarge: base.titleLarge?.copyWith(
            fontFamily: _fontFamily,
            color: displayColor,
          ),
          titleMedium: base.titleMedium?.copyWith(
            fontFamily: _fontFamily,
            color: bodyColor,
          ),
          titleSmall: base.titleSmall?.copyWith(
            fontFamily: _fontFamily,
            color: bodyColor,
          ),
          bodyLarge: base.bodyLarge?.copyWith(
            fontFamily: _fontFamily,
            color: bodyColor,
          ),
          bodyMedium: base.bodyMedium?.copyWith(
            fontFamily: _fontFamily,
            color: bodyColor,
          ),
          bodySmall: base.bodySmall?.copyWith(
            fontFamily: _fontFamily,
            color: bodyColor.withOpacity(0.8),
          ),
          labelLarge: base.labelLarge?.copyWith(
            fontFamily: _fontFamily,
            color: bodyColor,
            fontWeight: FontWeight.w500,
          ), // For buttons
          labelMedium: base.labelMedium?.copyWith(
            fontFamily: _fontFamily,
            color: bodyColor,
          ),
          labelSmall: base.labelSmall?.copyWith(
            fontFamily: _fontFamily,
            color: bodyColor.withOpacity(0.8),
          ),
        )
        .apply(
          fontFamily: _fontFamily,
          // bodyColor: bodyColor, // apply will override individual settings
          // displayColor: displayColor,
        );
  }
}
