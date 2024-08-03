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
        decoration: BoxDecoration(
          color: const Color(0xFFD2D2D2).withOpacity(0.5),
          borderRadius: BorderRadius.circular(30),
        ),
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 15.0, vertical: 15.0), // เพิ่ม padding ให้ใหญ่ขึ้น
          child: GNav(
            gap: 10, // เพิ่ม gap ระหว่างไอคอนและข้อความ
            activeColor: const Color(0xFF6D7278), // สีตัวหนังสือเมื่อ active
            iconSize: 30, // เพิ่มขนาดของไอคอน
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 12), // เพิ่ม padding ภายในปุ่ม
            duration: const Duration(milliseconds: 800),
            tabBackgroundColor: const Color(0xFFD2D2D2).withOpacity(
                0.8), // สีพื้นหลังเมื่อ active เป็นสี D2D2D2 โปร่งแสง 80%
            color: Colors.black,
            tabs: [
              GButton(
                icon: Icons.home,
                text: 'Home',
                leading: Image.asset(
                  'assets/icons/home_icon.png',
                  width: 30, // เพิ่มขนาดของรูปภาพ
                  height: 30, // เพิ่มขนาดของรูปภาพ
                ),
              ),
              GButton(
                icon: Icons.quiz,
                text: 'Quiz',
                leading: Image.asset(
                  'assets/icons/quiz_icon.png',
                  width: 30, // เพิ่มขนาดของรูปภาพ
                  height: 30, // เพิ่มขนาดของรูปภาพ
                ),
              ),
              GButton(
                icon: Icons.book,
                text: 'Vocab',
                leading: Image.asset(
                  'assets/icons/vocab_icon.png',
                  width: 30, // เพิ่มขนาดของรูปภาพ
                  height: 30, // เพิ่มขนาดของรูปภาพ
                ),
              ),
              GButton(
                icon: Icons.person,
                text: 'Profile',
                leading: Image.asset(
                  'assets/icons/profile_icon.png',
                  width: 30, // เพิ่มขนาดของรูปภาพ
                  height: 30, // เพิ่มขนาดของรูปภาพ
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
