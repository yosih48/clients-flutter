import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: Color(0xFF6200EE),
    scaffoldBackgroundColor: Color(0xFFF5F5F5),
    colorScheme: ColorScheme.light(
      primary: Color(0xFF6200EE),
      secondary: Color(0xFF03DAC6),
      surface: Colors.white,
      background: Color(0xFFF5F5F5),
      error: Color(0xFFB00020),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onBackground: Colors.black,
      onError: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF6200EE),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF6200EE),
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Color(0xFF6200EE),
        side: BorderSide(color: Color(0xFF6200EE), width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Color(0xFF6200EE),
        textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFF6200EE), width: 2),
      ),
      labelStyle: TextStyle(color: Colors.grey.shade700),
      floatingLabelStyle: TextStyle(color: Color(0xFF6200EE)),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: Color(0xFFBB86FC),
    scaffoldBackgroundColor: Color(0xFF121212),
    colorScheme: ColorScheme.dark(
      primary: Color(0xFFBB86FC),
      secondary: Color(0xFF03DAC6),
      surface: Color(0xFF1E1E1E),
      background: Color(0xFF121212),
      error: Color(0xFFCF6679),
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: Colors.black,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFBB86FC),
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Color(0xFFBB86FC),
        side: BorderSide(color: Color(0xFFBB86FC), width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Color(0xFFBB86FC),
        textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF2C2C2C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFFBB86FC), width: 2),
      ),
      labelStyle: TextStyle(color: Colors.grey.shade400),
      floatingLabelStyle: TextStyle(color: Color(0xFFBB86FC)),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    cardTheme: CardThemeData(
      color: Color(0xFF1E1E1E),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white70),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
    ),
  );
}
