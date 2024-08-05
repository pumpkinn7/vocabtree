import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeProvider(ThemeMode initialThemeMode);

  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDarkModeEnabled) {
    _themeMode = isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
