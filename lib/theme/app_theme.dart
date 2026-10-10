import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryRed = Color(0xFFFF6B6B);
  static const Color deepRed = Color.fromARGB(255, 161, 13, 13);

  static ThemeData darkTheme() {
    final seed = deepRed;
    return ThemeData.dark().copyWith(
      colorScheme:
          ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
      primaryColor: seed,
      scaffoldBackgroundColor: const Color(0xFF0B0B0B),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0D0D0D),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      cardColor: const Color(0xFF141414),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0D0D0D),
        selectedItemColor: primaryRed,
        unselectedItemColor: Colors.white70,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1C1C1C),
        hintStyle: const TextStyle(color: Colors.white70),
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryRed),
        ),
      ),
      dialogTheme: DialogThemeData(backgroundColor: const Color(0xFF121212)),
    );
  }
}
