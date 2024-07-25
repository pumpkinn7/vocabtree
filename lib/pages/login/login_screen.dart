// lib/pages/login/login_screen.dart

// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _login() async {
    if (_usernameEmailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบ')),
      );
      return;
    }

    String usernameOrEmail = _usernameEmailController.text.trim();
    String email = usernameOrEmail;

    // ตรวจสอบว่าเป็น email หรือไม่
    if (!usernameOrEmail.contains('@')) {
      // ถ้าไม่ใช่ email ให้ค้นหา email จาก username ใน Firestore
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: usernameOrEmail)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          email = querySnapshot.docs.first['email'];
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('ดูเหมือนจะยังไม่มีบัญชีนะ สมัครก่อนสิ')),
          );
          return;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
        return;
      }
    }

    // ดำเนินการ login ด้วย email และ password
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: _passwordController.text.trim(),
      );

      User user = userCredential.user!;
      await user.reload();
      user = FirebaseAuth.instance.currentUser!;

      if (!user.emailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('โปรดยืนยันอีเมลของคุณก่อนเข้าสู่ระบบ')),
        );
        await FirebaseAuth.instance.signOut(); // ลงชื่อออกจากระบบ
        return;
      }

      // Navigate to the home screen
      Navigator.pushNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('ดูเหมือนจะยังไม่มีบัญชีนะ สมัครก่อนสิ')),
        );
      } else if (e.code == 'wrong-password' ||
          e.message?.contains('The supplied auth credential is incorrect') ==
              true ||
          e.message?.contains(
                  'The supplied auth credential is malformed or has expired') ==
              true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ดูเหมือนว่ารหัสผ่านจะไม่ถูกต้องนะ')),
        );
      } else if (e.code == 'too-many-requests') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('พยายามเข้าสู่ระบบบ่อยเกินไป กรุณาลองใหม่ภายหลัง')),
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/tree_6977580.png',
                height: 150,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _usernameEmailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: 'ชื่อผู้ใช้งาน หรืออีเมล',
                  labelStyle: TextStyle(color: Colors.grey[700]),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: 'รหัสผ่าน',
                  labelStyle: TextStyle(color: Colors.grey[700]),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey[700],
                      ),
                      onPressed: _toggleObscureText,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Text.rich(
                  TextSpan(
                    text: 'ลืมรหัสผ่าน?',
                    style: const TextStyle(color: Colors.teal, fontSize: 14),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pushNamed(context, '/reset-password');
                      },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'เข้าสู่ระบบ',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text.rich(
                TextSpan(
                  text: 'ไม่มีบัญชีผู้ใช้งานใช่หรือไม่? ',
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                  children: [
                    TextSpan(
                      text: 'สมัครเลย',
                      style: const TextStyle(color: Colors.teal, fontSize: 14),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushNamed(context, '/register');
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
