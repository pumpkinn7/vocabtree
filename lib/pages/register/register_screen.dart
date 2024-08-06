import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vocabtree/pages/login/login_screen.dart';
import 'package:vocabtree/pages/otp/otp_verification_screen.dart';
import 'package:vocabtree/services/auth_service.dart';
import 'package:vocabtree/theme/text_styles.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  File? _imageFile;
  String? _profileImageUrl;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${DateTime.now().toIso8601String()}.jpg');
      await ref.putFile(_imageFile!);
      final url = await ref.getDownloadURL();
      setState(() {
        _profileImageUrl = url;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading image: $e');
      }
      _showErrorSnackBar('เกิดข้อผิดพลาดในการอัปโหลดรูปภาพ');
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_profileImageUrl == null) {
      _showErrorSnackBar('กรุณาอัปโหลดรูปภาพโปรไฟล์');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.registerUser(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        profileImageUrl: _profileImageUrl!,
      );

      setState(() {
        _isLoading = false;
      });

      if (result.success && result.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationScreen(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              username: _usernameController.text.trim(),
              profileImageFile: _imageFile,
              user: result.user!,
              profileImageUrl: _profileImageUrl!,
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Text(
                  'สวัสดี!\nสมัครสมาชิกเพื่อเข้าใช้งาน',
                  style: AppTextStyles.headline,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _buildUsernameAndProfileImage(),
                const SizedBox(height: 24),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 16),
                _buildConfirmPasswordField(),
                const SizedBox(height: 32),
                _buildRegisterButton(),
                const SizedBox(height: 24),
                _buildLoginLink(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameAndProfileImage() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'ชื่อผู้ใช้งาน',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              labelStyle: AppTextStyles.inputText,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'กรุณากรอกชื่อผู้ใช้งาน';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 20),
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  _imageFile != null ? FileImage(_imageFile!) : null,
              child: _imageFile == null
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
            CircleAvatar(
              backgroundColor: Colors.grey[700],
              radius: 18,
              child: IconButton(
                icon:
                    const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                onPressed: _pickImage,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'อีเมล',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        labelStyle: AppTextStyles.inputText,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'กรุณากรอกอีเมล';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'กรุณากรอกอีเมลให้ถูกต้อง';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'รหัสผ่าน',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        labelStyle: AppTextStyles.inputText,
        suffixIcon: IconButton(
          icon:
              Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
          onPressed: _togglePasswordVisibility,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'กรุณากรอกรหัสผ่าน';
        }
        if (value.length < 6) {
          return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      decoration: InputDecoration(
        labelText: 'ยืนยันรหัสผ่าน',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        labelStyle: AppTextStyles.inputText,
        suffixIcon: IconButton(
          icon: Icon(_obscureConfirmPassword
              ? Icons.visibility_off
              : Icons.visibility),
          onPressed: _toggleConfirmPasswordVisibility,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'กรุณายืนยันรหัสผ่าน';
        }
        if (value != _passwordController.text) {
          return 'รหัสผ่านไม่ตรงกัน';
        }
        return null;
      },
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _register,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'สมัครสมาชิก',
                style: AppTextStyles.label,
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
