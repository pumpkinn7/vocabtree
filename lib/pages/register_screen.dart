import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:vocabtree/pages/otp_screen.dart';

import 'login_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 20, top: 20),
            child: Image.asset(
              'assets/icons/back.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                  height: 100), // เพิ่มระยะห่างให้เนื้อหาอยู่ใต้ AppBar
              const Text(
                'สวัสดี!\nสมัครสมาชิกเพื่อเข้าใช้งาน',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: 'ชื่อผู้ใช้งาน',
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50, // ขนาดใหญ่ขึ้น
                        backgroundColor: Colors.grey[300],
                        child: const Icon(Icons.person,
                            size: 50, color: Colors.white),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[700],
                          radius: 15,
                          child: const Icon(Icons.camera_alt,
                              size: 15, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: 'อีเมล',
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
              ),
              const SizedBox(height: 30), // ระยะห่างระหว่างช่องกรอกข้อมูล
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: 'รหัสผ่าน',
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
              ),
              const SizedBox(height: 20), // ระยะห่างระหว่างช่องกรอกข้อมูล
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: 'ยืนยัน รหัสผ่าน',
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const OTPVerificationScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'สมัครสมาชิก',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Text.rich(
                  TextSpan(
                    text: 'มีบัญชีผู้ใช้งานอยู่แล้ว? ',
                    children: [
                      TextSpan(
                        text: 'เข้าสู่ระบบเลย',
                        style: const TextStyle(color: Colors.teal),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                            );
                          },
                      ),
                    ],
                  ),
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
