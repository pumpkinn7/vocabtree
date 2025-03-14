// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:vocabtree/core/theme/theme_provider.dart';
import 'package:vocabtree/features/home/screens/home_screen.dart';
import 'package:vocabtree/features/profile/screens/profile_screen.dart';
import 'package:vocabtree/features/quiz/screens/quiz_screen.dart';
import 'package:vocabtree/features/vocab/screens/vocab_screen.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomeScreen(),
    QuizScreen(),
    VocabScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkModeEnabled = themeProvider.themeMode == ThemeMode.dark;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: BootstrapRow(
          children: [
            BootstrapCol(
              sizes: 'col-xs-12 col-sm-12 col-md-8 col-lg-6',
              offsets: 'offset-xs-0 offset-sm-0 offset-md-2 offset-lg-3',
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkModeEnabled
                        ? Colors.grey[900]!.withOpacity(0.5)
                        : Colors.grey[300]!.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: _getHorizontalPadding(screenWidth),
                    vertical: _getVerticalPadding(screenWidth),
                  ),
                  child: GNav(
                    gap: _getGapSize(screenWidth),
                    activeColor: isDarkModeEnabled
                        ? Colors.white
                        : const Color(0xFF6D7278),
                    iconSize: _getIconSize(screenWidth),
                    padding: EdgeInsets.symmetric(
                      horizontal: _getTabPadding(screenWidth),
                      vertical: 12,
                    ),
                    tabBackgroundColor: isDarkModeEnabled
                        ? Colors.grey[800]!.withOpacity(0.8)
                        : Colors.grey[400]!.withOpacity(0.8),
                    color: isDarkModeEnabled ? Colors.white70 : Colors.black,
                    tabs: _buildResponsiveTabs(screenWidth),
                    selectedIndex: _selectedIndex,
                    onTabChange: _onItemTapped,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getHorizontalPadding(double width) {
    if (width < 576) return 8;
    if (width < 768) return 12;
    if (width < 992) return 15;
    return 15;
  }

  double _getVerticalPadding(double width) {
    if (width < 576) return 10;
    if (width < 768) return 12;
    if (width < 992) return 15;
    return 15;
  }

  double _getGapSize(double width) {
    if (width < 576) return 4;
    if (width < 768) return 6;
    if (width < 992) return 8;
    return 10;
  }

  double _getIconSize(double width) {
    if (width < 576) return 24;
    if (width < 768) return 26;
    if (width < 992) return 28;
    return 30;
  }

  double _getTabPadding(double width) {
    if (width < 576) return 12;
    if (width < 768) return 15;
    if (width < 992) return 18;
    return 20;
  }

  List<GButton> _buildResponsiveTabs(double width) {
    double iconSize = _getIconSize(width);

    return [
      GButton(
        icon: Icons.home,
        text: 'หน้าหลัก',
        leading: Image.asset(
          'assets/icons/home_icon.png',
          width: iconSize,
          height: iconSize,
        ),
      ),
      GButton(
        icon: Icons.quiz,
        text: 'ทดสอบ',
        leading: Image.asset(
          'assets/icons/quiz_icon.png',
          width: iconSize,
          height: iconSize,
        ),
      ),
      GButton(
        icon: Icons.book,
        text: 'คลัง',
        leading: Image.asset(
          'assets/icons/vocab_icon.png',
          width: iconSize,
          height: iconSize,
        ),
      ),
      GButton(
        icon: Icons.person,
        text: 'โปรไฟล์',
        leading: Image.asset(
          'assets/icons/profile_icon.png',
          width: iconSize,
          height: iconSize,
        ),
      ),
    ];
  }
}
