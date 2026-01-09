import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.inter().fontFamily, // Inter for modern look
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4E93E6), // Key Blue from reference
      brightness: Brightness.light,
      primary: const Color(0xFF4E93E6), // "On Going" Blue
      secondary: const Color(0xFFEFA545), // "In Process" Yellow/Orange
      tertiary: const Color(0xFF4DB6AC), // "Completed" Teal/Green
      error: const Color(0xFFE57373), // "Canceled" Red
      surface: const Color(0xFFFFFFFF), // Pure White Cards
      background: const Color(0xFFF5F5F5), // Light Grey Background
      onSurface: const Color(0xFF1D1B20), // Dark Grey Text
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    textTheme: GoogleFonts.interTextTheme().copyWith(
      headlineLarge: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 32, color: const Color(0xFF1D1B20)),
      headlineMedium: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 28, color: const Color(0xFF1D1B20)),
      titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 22, color: const Color(0xFF1D1B20)),
      titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16, color: const Color(0xFF1D1B20)),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(color: Colors.black87),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0, // We will use manual shadows for custom blur
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: EdgeInsets.all(0),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF4E93E6), width: 2),
      ),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.inter().fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4E93E6),
      brightness: Brightness.dark,
      surface: const Color(0xFF2C2C2E),
      background: const Color(0xFF1C1C1E),
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF1C1C1E),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF2C2C2E),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF3A3A3C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF4E93E6), width: 2),
      ),
    ),
  );
}
