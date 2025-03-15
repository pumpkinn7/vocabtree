import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vocabtree/core/utils/responsive_helper.dart';
import 'package:vocabtree/features/auth/widgets/register/username_profile_section.dart';
import 'package:vocabtree/features/auth/widgets/register/email_field.dart';
import 'package:vocabtree/features/auth/widgets/register/password_field.dart';
import 'package:vocabtree/features/auth/widgets/register/register_button.dart';

class RegisterForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final bool isLoading;
  final Function({
    required String username,
    required String email,
    required String password,
    required XFile? imageFile,
    required String? profileImageUrl,
  }) onSubmit;

  const RegisterForm({
    super.key,
    required this.formKey,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  XFile? _imageFile;
  String? _profileImageUrl;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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

  void _updateImageData({XFile? imageFile, String? profileImageUrl}) {
    setState(() {
      _imageFile = imageFile;
      _profileImageUrl = profileImageUrl;
    });
  }

  void _handleSubmit() {
    // เพิ่มการตรวจสอบรหัสผ่านก่อนส่งฟอร์ม
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('รหัสผ่านและยืนยันรหัสผ่านไม่ตรงกัน')),
      );
      return;
    }

    widget.onSubmit(
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      imageFile: _imageFile,
      profileImageUrl: _profileImageUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    final verticalSpacing = ResponsiveHelper.getVerticalSpacing(context) *
        0.7; // ลดระยะห่างระหว่างช่องกรอก

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UsernameProfileSection(
            usernameController: _usernameController,
            imageFile: _imageFile,
            onImageUpdate: _updateImageData,
          ),
          SizedBox(height: verticalSpacing),
          EmailField(controller: _emailController),
          SizedBox(height: verticalSpacing),
          PasswordField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            toggleVisibility: _togglePasswordVisibility,
          ),
          SizedBox(height: verticalSpacing),
          PasswordField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            toggleVisibility: _toggleConfirmPasswordVisibility,
            isConfirmField: true,
            otherPasswordController: _passwordController,
          ),
          SizedBox(height: verticalSpacing * 1.2),
          RegisterButton(
            isLoading: widget.isLoading,
            onPressed: _handleSubmit,
          ),
        ],
      ),
    );
  }
}
