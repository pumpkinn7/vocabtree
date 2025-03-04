import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vocabtree/features/auth/screens/login_screen.dart';
import 'package:vocabtree/features/auth/screens/otp_verification_screen.dart';
import 'package:vocabtree/features/auth/services/auth_service.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import 'package:vocabtree/core/utils/responsive_helper.dart';
import 'package:vocabtree/features/auth/widgets/register/register_form.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleFormSubmit({
    required String username,
    required String email,
    required String password,
    required File? imageFile,
    required String? profileImageUrl,
  }) async {
    if (_formKey.currentState!.validate()) {
      if (profileImageUrl == null) {
        _showErrorSnackBar('กรุณาอัปโหลดรูปภาพโปรไฟล์');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final result = await _authService.registerUser(
          username: username.trim(),
          email: email.trim(),
          password: password,
          profileImageUrl: profileImageUrl,
        );

        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        if (result.success && result.user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OTPVerificationScreen(
                email: email.trim(),
                password: password,
                username: username.trim(),
                profileImageFile: imageFile,
                user: result.user!,
                profileImageUrl: profileImageUrl,
              ),
            ),
          );
        } else {
          _showErrorSnackBar(
              result.errorMessage ?? 'เกิดข้อผิดพลาดในการลงทะเบียน');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error in _register: $e');
        }
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('เกิดข้อผิดพลาดในการลงทะเบียน: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('ลงทะเบียนใช้งาน'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getScreenWidth(context) * 0.05,
            vertical: ResponsiveHelper.getScreenWidth(context) *
                0.02, // ลดระยะห่างด้านบน-ล่าง
          ),
          child: Center(
            child: FractionallySizedBox(
              widthFactor: ResponsiveHelper.getContentWidth(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                      height:
                          ResponsiveHelper.getVerticalSpacing(context) * 0.2),
                  Text(
                    'สวัสดี!\nสมัครสมาชิกเพื่อเข้าใช้งาน',
                    style: AppTextStyles.headline,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                      height:
                          ResponsiveHelper.getVerticalSpacing(context) * 0.5),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(
                          ResponsiveHelper.getScreenWidth(context) * 0.04),
                      child: RegisterForm(
                        formKey: _formKey,
                        isLoading: _isLoading,
                        onSubmit: _handleFormSubmit,
                      ),
                    ),
                  ),
                  SizedBox(
                      height: ResponsiveHelper.getVerticalSpacing(context)),
                  _buildLoginLink(),
                  SizedBox(
                      height: ResponsiveHelper.getVerticalSpacing(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        },
        child: Text.rich(
          TextSpan(
            text: 'มีบัญชีผู้ใช้งานอยู่แล้ว? ',
            style: AppTextStyles.label,
            children: [
              TextSpan(
                text: 'เข้าสู่ระบบเลย',
                style: AppTextStyles.label.copyWith(color: Colors.orange),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
