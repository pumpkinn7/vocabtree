import 'package:flutter/material.dart';

class SeasonThemeProvider {
  static Map<String, Map<String, dynamic>> getSeasonThemes() {
    return {
      'B1': {
        'icon': Icons.local_florist,
        'iconColor': Colors.green[400],
        'image': 'assets/images/spring.png',
        'description': 'Spring - ระดับพื้นฐานถึงปานกลาง',
        'name': 'SPRING',
      },
      'B2': {
        'icon': Icons.wb_sunny,
        'iconColor': Colors.amber[600],
        'image': 'assets/images/summer.png',
        'description': 'Summer - ระดับปานกลาง',
        'name': 'SUMMER',
      },
      'C1': {
        'icon': Icons.eco,
        'iconColor': Colors.deepOrange[400],
        'image': 'assets/images/autumn.png',
        'description': 'Autumn - ระดับกลางค่อนข้างสูง',
        'name': 'AUTUMN',
      },
      'C2': {
        'icon': Icons.ac_unit,
        'iconColor': Colors.blueGrey[400],
        'image': 'assets/images/winter.png',
        'description': 'Winter - ระดับสูง',
        'name': 'WINTER',
      },
    };
  }

  static Map<String, dynamic> getThemeForLevel(String level) {
    final themes = getSeasonThemes();
    return themes[level] ?? themes['B1']!;
  }
}
