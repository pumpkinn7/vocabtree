// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:vocabtree/theme/text_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  void _toggleObscureText() => setState(() => _obscureText = !_obscureText);

  Future<void> _login() async {
    if (_usernameEmailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showErrorMessage('กรุณากรอกข้อมูลให้ครบก่อนสิ');
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
        _showErrorMessage('ดูเหมือนจะยังไม่มีบัญชีนะ สมัครก่อนสิ');
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
      _showErrorMessage('โปรดยืนยันอีเมลของคุณก่อนเข้าสู่ระบบ');
      await FirebaseAuth.instance.signOut();
      return;
    }

    Navigator.pushNamed(context, '/home');
  }

  void _handleFirebaseAuthException(FirebaseAuthException e) {
    if (e.code == 'user-not-found') {
      _showErrorMessage('ดูเหมือนจะยังไม่มีบัญชีนะ สมัครก่อนสิ');
    } else if (e.code == 'wrong-password' ||
        e.message?.contains('The supplied auth credential is incorrect') ==
            true ||
        e.message?.contains(
                'The supplied auth credential is malformed or has expired') ==
            true) {
      _showErrorMessage('ดูเหมือนว่ารหัสผ่านจะไม่ถูกต้องนะ');
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogo(),
              const SizedBox(height: 40),
              _buildUsernameEmailField(),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 16),
              _buildForgotPasswordLink(),
              const SizedBox(height: 24),
              _buildLoginButton(),
              const SizedBox(height: 35),
              _buildRegisterLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset('assets/images/tree_6977580.png', height: 150);
  }

  Widget _buildUsernameEmailField() {
    return _buildTextField(
        _usernameEmailController, 'ชื่อผู้ใช้งาน หรืออีเมล', false);
  }

  Widget _buildPasswordField() {
    return _buildTextField(_passwordController, 'รหัสผ่าน', true);
  }

  Widget _buildTextField(
      TextEditingController controller, String label, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscureText : false,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        labelText: label,
        labelStyle: AppTextStyles.inputText,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: _toggleObscureText,
              )
            : null,
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: Text.rich(
        TextSpan(
          text: 'ลืมรหัสผ่าน?',
          style: AppTextStyles.label.copyWith(color: Colors.grey),
          recognizer: TapGestureRecognizer()
            ..onTap = () => Navigator.pushNamed(context, '/reset-password'),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _login,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text('เข้าสู่ระบบ',
            style: AppTextStyles.label.copyWith(color: Colors.white)),
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
