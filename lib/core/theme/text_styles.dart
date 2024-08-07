import 'package:flutter/material.dart';

class AppTextStyles {
  static const TextStyle headline = TextStyle(
    fontFamily: 'Kanit',
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle caption = TextStyle(
    fontFamily: 'Kanit',
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.grey[600],
  );

  static const TextStyle label = TextStyle(
    fontFamily: 'Kanit',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Color(0xFF6D7278),
  );

  static const TextStyle inputText = TextStyle(
    fontFamily: 'Kanit',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: Color(0xFF6D7278),
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
