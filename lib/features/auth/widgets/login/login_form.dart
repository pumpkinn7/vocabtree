import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import 'package:vocabtree/features/auth/widgets/login/login_text_field.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController usernameEmailController;
  final TextEditingController passwordController;
  final bool obscureText;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;

  const LoginForm({
    super.key,
    required this.usernameEmailController,
    required this.passwordController,
    required this.obscureText,
    required this.onTogglePassword,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoginTextField(
              controller: usernameEmailController,
              label: 'ชื่อผู้ใช้งาน หรืออีเมล',
              isPassword: false,
            ),
            const SizedBox(height: 16),
            LoginTextField(
              controller: passwordController,
              label: 'รหัสผ่าน',
              isPassword: true,
              obscureText: obscureText,
              onTogglePassword: onTogglePassword,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onLogin,
                child: Text('เข้าสู่ระบบ', style: AppTextStyles.label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
