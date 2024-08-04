import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static final TextStyle headline = GoogleFonts.kanit(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle caption = GoogleFonts.kanit(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.grey[600],
  );

  static final TextStyle label = GoogleFonts.kanit(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF6D7278),
  );

  static final TextStyle inputText = GoogleFonts.kanit(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF6D7278),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    textTheme: TextTheme(
      headlineMedium: headline,
      bodyLarge: inputText,
      titleMedium: label,
      bodySmall: caption,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    textTheme: TextTheme(
      headlineMedium: headline.copyWith(color: Colors.white),
      bodyLarge: inputText.copyWith(color: Colors.white70),
      titleMedium: label.copyWith(color: Colors.white70),
      bodySmall: caption.copyWith(color: Colors.grey[300]),
    ),
  );
}
