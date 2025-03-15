// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import 'package:vocabtree/features/auth/widgets/login/login_form.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _usernameEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleObscureText() => setState(() => _obscureText = !_obscureText);

  Future<void> _login() async {
    if (_usernameEmailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showErrorMessage('กรุณากรอกข้อมูลให้ครบถ้วน');
      return;
    }

    String usernameOrEmail = _usernameEmailController.text.trim();
    String email = await _getEmail(usernameOrEmail);
    if (email.isEmpty) return;

    try {
      await _signInWithEmailAndPassword(email);
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthException(e);
    } catch (e) {
      _showErrorMessage('เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }

  Future<String> _getEmail(String usernameOrEmail) async {
    if (usernameOrEmail.contains('@')) return usernameOrEmail;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('profiles')
          .where('username', isEqualTo: usernameOrEmail)
          .get();

      if (querySnapshot.docs.isEmpty) {
        _showErrorMessage('ไม่พบบัญชีผู้ใช้งานนี้');
        return '';
      }

      String userId = querySnapshot.docs.first['userId'];
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return userDoc['email'];
    } catch (e) {
      _showErrorMessage('เกิดข้อผิดพลาด: ${e.toString()}');
      return '';
    }
  }

  Future<void> _signInWithEmailAndPassword(String email) async {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: _passwordController.text.trim(),
    );

    User user = userCredential.user!;
    await user.reload();
    user = FirebaseAuth.instance.currentUser!;

    if (!user.emailVerified) {
      _showErrorMessage('กรุณายืนยันอีเมลก่อนเข้าสู่ระบบ');
      await FirebaseAuth.instance.signOut();
    } else {
      // ตรวจสอบและสร้างข้อมูลความคืบหน้าเริ่มต้นสำหรับผู้ใช้
      await _checkAndInitializeUserProgress(user.uid);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  Future<void> _checkAndInitializeUserProgress(String userId) async {
    final progressDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('progress')
        .doc('unlockedTopics');

    final snapshot = await progressDoc.get();
    if (!snapshot.exists) {
      // สร้างข้อมูลการปลดล็อคเริ่มต้น
      final Map<String, Map<String, bool>> progressData = {
        'B1': {
          'daily_life': true,
          'education': false,
          'entertainment': false,
          'environment_and_nature': false,
          'food_and_dining': false,
          'health_and_medical': false,
          'technology': false,
          'travel_and_tourism': false,
        },
        'B2': {
          'cooking_and_culinary_skills': false,
          'fitness_and_exercise': false,
          'gardening_and_landscaping': false,
          'hobbies_and_crafts': false,
          'home_renovation_and_decor': false,
          'music_and_performing_arts': false,
          'outdoor_activities_and_adventures': false,
          'pet_care_and_animal_welfare': false,
        },
        'C1': {
          'creative_writing': false,
          'cultural_festivals': false,
          'digital_well_being': false,
          'event_planning': false,
          'fashion_trends': false,
          'interior_decorating': false,
          'nutrition_and_wellness': false,
          'urban_living': false,
        },
        'C2': {
          'adrenaline_activities': false,
          'cosmic_discoveries': false,
          'criminal_investigation': false,
          'digital_finance': false,
          'immersive_technologies': false,
          'legends_and_lore': false,
          'smart_automation': false,
        }
      };

      // บันทึกข้อมูลลง Firestore
      await progressDoc.set(progressData);
    }
  }

  void _handleFirebaseAuthException(FirebaseAuthException e) {
    if (e.code == 'user-not-found') {
      _showErrorMessage('ไม่พบบัญชีผู้ใช้งานนี้');
    } else if (e.code == 'wrong-password' ||
        e.message?.contains('The supplied auth credential is incorrect') ==
            true ||
        e.message?.contains(
                'The supplied auth credential is malformed or has expired') ==
            true) {
      _showErrorMessage('รหัสผ่านไม่ถูกต้อง');
    } else if (e.code == 'too-many-requests') {
      _showErrorMessage('พยายามเข้าสู่ระบบบ่อยเกินไป กรุณาลองใหม่ภายหลัง');
    } else {
      _showErrorMessage('เกิดข้อผิดพลาด: ${e.message}');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: BootstrapContainer(
            fluid: true,
            children: [
              BootstrapRow(
                children: [
                  BootstrapCol(
                    sizes: 'col-xs-12 col-sm-12 col-md-8 col-lg-4',
                    offsets: 'offset-xs-0 offset-sm-0 offset-md-2 offset-lg-4',
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        Image.asset(
                          'assets/images/tree_6977580.png',
                          height: 200,
                        ),
                        const SizedBox(height: 30),
                        LoginForm(
                          usernameEmailController: _usernameEmailController,
                          passwordController: _passwordController,
                          obscureText: _obscureText,
                          onTogglePassword: _toggleObscureText,
                          onLogin: _login,
                        ),
                        const SizedBox(height: 15),
                        _buildForgotPasswordLink(),
                        const SizedBox(height: 30),
                        _buildRegisterLink(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => Navigator.pushNamed(context, '/reset-password'),
        child: Text(
          'ลืมรหัสผ่าน?',
          style: AppTextStyles.label.copyWith(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Text.rich(
      TextSpan(
        text: 'ไม่มีบัญชีผู้ใช้งานใช่หรือไม่? ',
        style: AppTextStyles.label,
        children: [
          TextSpan(
            text: 'สมัครเลย',
            style: AppTextStyles.label.copyWith(color: Colors.orange),
            recognizer: TapGestureRecognizer()
              ..onTap = () => Navigator.pushNamed(context, '/register'),
          ),
        ],
      ),
    );
  }
}
