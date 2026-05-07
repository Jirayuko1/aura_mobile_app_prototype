import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color bgColor = Color(0xFFF7F6F1);
  static const Color primaryColor = Color(0xFFC09D3E);
  static const Color cardColor = Colors.white;
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textLight = Color(0xFF757575);

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: bgColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        surface: cardColor,
        onSurface: textDark,
      ),
      textTheme: GoogleFonts.promptTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          color: textDark,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          color: textDark,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: GoogleFonts.prompt(
          color: textDark,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          color: textDark,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.prompt(
          color: textDark,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.prompt(
          color: textDark,
        ),
        bodyMedium: GoogleFonts.prompt(
          color: textDark,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textDark),
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF101828), // Dark navy color for buttons
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF7C6228),
          side: const BorderSide(color: Color(0xFF7C6228)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 16,
      ),
    );
  }
}
