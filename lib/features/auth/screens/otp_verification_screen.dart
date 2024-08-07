// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  final String password;
  final String username;
  final File? profileImageFile;
  final User user;
  final String profileImageUrl;

  const OTPVerificationScreen({
    super.key,
    required this.email,
    required this.password,
    required this.username,
    this.profileImageFile,
    required this.user,
    required this.profileImageUrl,
  });

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  User? user;
  bool isUserCreated = false;

  Future<void> _verifyEmail() async {
    try {
      await user!.reload();
      User? refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser != null && refreshedUser.emailVerified) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(refreshedUser.uid)
            .set({
          'username': widget.username,
          'email': widget.email,
          'profileImageUrl': widget.profileImageUrl,
        });

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/account-success',
          (Route<dynamic> route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('อีเมลยังไม่ได้รับการยืนยัน')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _resendVerificationEmail() async {
    try {
      await user!.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ลิงก์ยืนยันถูกส่งไปที่อีเมลของคุณแล้ว')),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เราส่งไปแล้วนะ รอเวลาสักครู่ค่อยลองกดใหม่'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
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
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: widget.profileImageFile != null
                      ? FileImage(widget.profileImageFile!)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'สวัสดีคุณ, ${widget.username}',
                  style: AppTextStyles.headline,
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'เราได้ส่ง Link ยืนยัน OTP\nไปที่อีเมลของคุณเรียบร้อยแล้ว กดยืนยันเพื่อเข้าใช้งาน',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.label,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _verifyEmail,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'ยืนยัน',
                    style: AppTextStyles.label,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'ฉันยังไม่ได้รับรหัสยืนยัน? ',
                    style: AppTextStyles.label,
                    children: [
                      TextSpan(
                        text: 'ส่งอีกครั้ง',
                        style:
                            AppTextStyles.label.copyWith(color: Colors.orange),
                        recognizer: TapGestureRecognizer()
                          ..onTap = _resendVerificationEmail,
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
