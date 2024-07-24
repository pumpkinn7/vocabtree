// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class OTPVerificationScreen extends StatelessWidget {
  final User user;
  final String profileImageUrl;

  const OTPVerificationScreen({
    super.key,
    required this.user,
    required this.profileImageUrl,
  });

  Future<void> _verifyOTP(BuildContext context, String otp) async {
    try {
      await user.reload();
      if (user.emailVerified) {
        Navigator.pushNamed(context, '/account-success');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('รหัส OTP ไม่ถูกต้องหรืออีเมลยังไม่ได้รับการยืนยัน')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _resendOTP() async {
    try {
      await user.sendEmailVerification();
    } catch (e) {
      print('Error resending email verification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final otpController = TextEditingController();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 20, top: 20),
            child: Icon(Icons.arrow_back, color: Colors.black),
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
              const SizedBox(height: 100),
              const Text(
                'OTP! เราได้ส่งไปที่อีเมลคุณ',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: NetworkImage(profileImageUrl),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: otpController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: 'รหัส OTP',
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _verifyOTP(context, otpController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'ยืนยัน',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'ฉันยังไม่ได้รับรหัสยืนยัน? ',
                    style: const TextStyle(color: Colors.black54),
                    children: [
                      TextSpan(
                        text: 'ส่งอีกครั้ง',
                        style: const TextStyle(color: Colors.teal),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _resendOTP();
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
