// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:vocabtree/features/home/home_screen.dart';
import 'package:vocabtree/features/profile/profile_screen.dart';
import 'package:vocabtree/features/quiz/quiz_screen.dart';
import 'package:vocabtree/features/vocab/vocab_screen.dart';
import 'package:vocabtree/core/theme/theme_provider.dart';

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

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDarkModeEnabled
              ? Colors.grey[900]!.withOpacity(0.5)
              : Colors.grey[300]!.withOpacity(0.5),
          borderRadius: BorderRadius.circular(30),
        ),
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
          child: GNav(
            gap: 10,
            activeColor:
                isDarkModeEnabled ? Colors.white : const Color(0xFF6D7278),
            iconSize: 30,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 800),
            tabBackgroundColor: isDarkModeEnabled
                ? Colors.grey[800]!.withOpacity(0.8)
                : Colors.grey[400]!
                    .withOpacity(0.8), // ปรับสี hover ให้เข้มขึ้นใน light mode
            color: isDarkModeEnabled ? Colors.white70 : Colors.black,
            tabs: [
              GButton(
                icon: Icons.home,
                text: 'Home',
                leading: Image.asset(
                  'assets/icons/home_icon.png',
                  width: 30,
                  height: 30,
                ),
              ),
              GButton(
                icon: Icons.quiz,
                text: 'Quiz',
                leading: Image.asset(
                  'assets/icons/quiz_icon.png',
                  width: 30,
                  height: 30,
                ),
              ),
              GButton(
                icon: Icons.book,
                text: 'Vocab',
                leading: Image.asset(
                  'assets/icons/vocab_icon.png',
                  width: 30,
                  height: 30,
                ),
              ),
              GButton(
                icon: Icons.person,
                text: 'Profile',
                leading: Image.asset(
                  'assets/icons/profile_icon.png',
                  width: 30,
                  height: 30,
                ),
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: _onItemTapped,
          ),
        ),
      ),
    );
  }
}
