// lib/pages/home/home_screen.dart

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('หน้าหลัก'),
        backgroundColor: Colors.black,
      ),
      body: const Center(
        child: Text(
          'ยินดีต้อนรับสู่หน้าหลัก!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
