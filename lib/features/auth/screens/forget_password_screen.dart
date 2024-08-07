// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();

  final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกอีเมล')),
      );
      return;
    }

    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('อีเมลไม่ถูกต้อง')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('ลิงก์รีเซ็ตรหัสผ่านถูกส่งไปที่อีเมลของคุณแล้ว')),
      );
      Navigator.of(context).pop(true); // ส่งค่า true กลับไป
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('รีเซ็ตรหัสผ่าน'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
                child: Image.asset(
                  'assets/icons/Voodoo.png',
                  height: 150,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'รีเซ็ตรหัสผ่าน',
                style: AppTextStyles.headline,
              ),
              const SizedBox(height: 20),
              Text(
                'กรุณากรอกที่อยู่อีเมลที่เชื่อมโยงกับบัญชีของคุณเพื่อรับลิงก์รีเซ็ตรหัสผ่าน',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: 'อีเมลที่ท่านเชื่อมโยงบัญชี',
                  labelStyle: AppTextStyles.inputText,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _resetPassword,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'ส่งลิงก์รีเซ็ตรหัสผ่าน',
                    style: AppTextStyles.label,
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
