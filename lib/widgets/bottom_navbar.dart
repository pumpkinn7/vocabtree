// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:vocabtree/pages/home/home_screen.dart';
import 'package:vocabtree/pages/profile/profile_screen.dart';
import 'package:vocabtree/pages/quiz_screen/quiz_screen.dart';
import 'package:vocabtree/pages/vocab/vocab_screen.dart';

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
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          child: GNav(
            gap: 8,
            activeColor: Colors.black,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            duration: const Duration(milliseconds: 800),
            tabBackgroundColor: Colors.grey[300]!,
            color: Colors.black,
            tabs: [
              GButton(
                icon: Icons.home,
                text: 'Home',
                leading: Image.asset('assets/icons/home_icon.png',
                    width: 24, height: 24), // เพิ่มไฟล์รูปภาพ
              ),
              GButton(
                icon: Icons.quiz,
                text: 'Quiz',
                leading: Image.asset('assets/icons/quiz_icon.png',
                    width: 24, height: 24), // เพิ่มไฟล์รูปภาพ
              ),
              GButton(
                icon: Icons.book,
                text: 'Vocab',
                leading: Image.asset('assets/icons/vocab_icon.png',
                    width: 24, height: 24), // เพิ่มไฟล์รูปภาพ
              ),
              GButton(
                icon: Icons.person,
                text: 'Profile',
                leading: Image.asset('assets/icons/profile_icon.png',
                    width: 24, height: 24), // เพิ่มไฟล์รูปภาพ
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
