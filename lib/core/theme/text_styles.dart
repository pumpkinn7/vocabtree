import 'package:flutter/material.dart';

/// คลาสนี้กำหนด Text Styles และ Theme ที่ใช้ทั่วทั้งแอป VocabTree
class AppTextStyles {
  // ป้องกันการสร้าง instance
  AppTextStyles._();
  // สีหลักของแอป - โทนฤดูใบไม้ร่วงผสมหิมะ
  static const Color primaryColor = Color.fromARGB(255, 195, 147, 224);
  static const Color primaryDarkColor = Color.fromARGB(255, 132, 176, 214);
  static const Color accentColor = Color.fromARGB(255, 219, 130, 163);
  static const Color secondaryColor = Color.fromARGB(255, 62, 150, 233);

  // สีสำหรับข้อความและองค์ประกอบอื่น ๆ ในโหมดกลางวัน
  static const Color _lightTextColor = Color(0xFF4A4E69);
  static const Color _lightSubtextColor = Color(0xFF9A8C98);
  static const Color _lightBackgroundColor = Color(0xFFF8F7FF);
  static const Color _lightCardColor = Colors.white;
  static const Color _lightDividerColor = Color(0xFFE5E5E5);

  // สีสำหรับข้อความและองค์ประกอบอื่น ๆ ในโหมดกลางคืน
  static const Color _darkTextColor = Color(0xFFF5F5F5);
  static const Color _darkSubtextColor = Color(0xFFBDBDBD);
  static const Color _darkBackgroundColor = Color(0xFF121212);
  static const Color _darkCardColor = Color(0xFF1E1E1E);
  static const Color _darkDividerColor = Color(0xFF424242);

  // ฟอนท์หลักของแอป (ใช้ฟอนท์ Kanit ซึ่งมีในโปรเจค)
  static TextStyle get _baseTextStyle => TextStyle(
        fontFamily: 'Kanit',
        letterSpacing: 0.5,
        height: 1.2,
      );

  // Text styles สำหรับหัวข้อและเนื้อหาต่าง ๆ
  static TextStyle get headline => _baseTextStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get title => _baseTextStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get subtitle => _baseTextStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get body => _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get caption => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w300,
        color: _lightSubtextColor,
      );

  static TextStyle get label => _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get inputText => _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get buttonText => _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.0,
      );

  // กำหนดธีมสำหรับโหมดกลางวัน (Light Theme)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        background: _lightBackgroundColor,
        surface: _lightCardColor,
        onBackground: _lightTextColor,
        onSurface: _lightTextColor,
      ),
      scaffoldBackgroundColor: _lightBackgroundColor,
      cardColor: _lightCardColor,
      dividerColor: _lightDividerColor,
      textTheme: TextTheme(
        displayLarge: headline.copyWith(color: _lightTextColor),
        displayMedium: title.copyWith(color: _lightTextColor),
        displaySmall: subtitle.copyWith(color: _lightTextColor),
        bodyLarge: body.copyWith(color: _lightTextColor),
        bodyMedium: body.copyWith(color: _lightTextColor),
        bodySmall: caption.copyWith(color: _lightSubtextColor),
        labelLarge: label.copyWith(color: _lightTextColor),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _lightCardColor,
        foregroundColor: _lightTextColor,
        elevation: 0,
        titleTextStyle: title.copyWith(color: _lightTextColor),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _lightCardColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: _lightSubtextColor,
      ),
      elevatedButtonTheme: _lightGlassButtonTheme,
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: buttonText,
          side: const BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: buttonText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: label.copyWith(color: _lightSubtextColor),
        hintStyle: body.copyWith(color: _lightSubtextColor.withOpacity(0.7)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _lightDividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: primaryColor),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _lightCardColor,
        labelStyle: caption.copyWith(color: _lightTextColor),
        side: BorderSide(color: _lightDividerColor),
      ),
      tabBarTheme: TabBarTheme(
        labelColor: primaryColor,
        unselectedLabelColor: _lightSubtextColor,
        labelStyle: label,
        unselectedLabelStyle: label,
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: body.copyWith(color: _lightTextColor),
        subtitleTextStyle: caption.copyWith(color: _lightSubtextColor),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: _lightCardColor,
        titleTextStyle: title.copyWith(color: _lightTextColor),
        contentTextStyle: body.copyWith(color: _lightTextColor),
      ),
    );
  }

  // กำหนดธีมสำหรับโหมดกลางคืน (Dark Theme)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryDarkColor,
      colorScheme: ColorScheme.dark(
        primary: primaryDarkColor,
        secondary: accentColor,
        background: _darkBackgroundColor,
        surface: _darkCardColor,
        onBackground: _darkTextColor,
        onSurface: _darkTextColor,
      ),
      scaffoldBackgroundColor: _darkBackgroundColor,
      cardColor: _darkCardColor,
      dividerColor: _darkDividerColor,
      textTheme: TextTheme(
        displayLarge: headline.copyWith(color: _darkTextColor),
        displayMedium: title.copyWith(color: _darkTextColor),
        displaySmall: subtitle.copyWith(color: _darkTextColor),
        bodyLarge: body.copyWith(color: _darkTextColor),
        bodyMedium: body.copyWith(color: _darkTextColor),
        bodySmall: caption.copyWith(color: _darkSubtextColor),
        labelLarge: label.copyWith(color: _darkTextColor),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _darkCardColor,
        foregroundColor: _darkTextColor,
        elevation: 0,
        titleTextStyle: title.copyWith(color: _darkTextColor),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _darkCardColor,
        selectedItemColor: accentColor,
        unselectedItemColor: _darkSubtextColor,
      ),
      elevatedButtonTheme: _darkGlassButtonTheme,
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentColor,
          textStyle: buttonText,
          side: const BorderSide(color: accentColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
          textStyle: buttonText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkCardColor,
        labelStyle: label.copyWith(color: _darkSubtextColor),
        hintStyle: body.copyWith(color: _darkSubtextColor.withOpacity(0.7)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _darkDividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: accentColor),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _darkCardColor,
        labelStyle: caption.copyWith(color: _darkTextColor),
        side: BorderSide(color: _darkDividerColor),
      ),
      tabBarTheme: TabBarTheme(
        labelColor: accentColor,
        unselectedLabelColor: _darkSubtextColor,
        labelStyle: label,
        unselectedLabelStyle: label,
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: body.copyWith(color: _darkTextColor),
        subtitleTextStyle: caption.copyWith(color: _darkSubtextColor),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: _darkCardColor,
        titleTextStyle: title.copyWith(color: _darkTextColor),
        contentTextStyle: body.copyWith(color: _darkTextColor),
      ),
    );
  }

  // แก้ไข ElevatedButtonThemeData ในส่วน lightTheme
  static ElevatedButtonThemeData get _lightGlassButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: _lightTextColor,
          textStyle: buttonText,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.grey[300]!),
          ),
        ),
      );

  // แก้ไข ElevatedButtonThemeData ในส่วน darkTheme
  static ElevatedButtonThemeData get _darkGlassButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkCardColor,
          foregroundColor: _darkTextColor,
          textStyle: buttonText,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.grey[700]!),
          ),
        ),
      );
}
