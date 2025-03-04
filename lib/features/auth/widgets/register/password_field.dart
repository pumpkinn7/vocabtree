import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback toggleVisibility;
  final bool isConfirmField;
  final String? passwordToMatch;

  const PasswordField({
    super.key,
    required this.controller,
    required this.obscureText,
    required this.toggleVisibility,
    this.isConfirmField = false,
    this.passwordToMatch,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: isConfirmField ? 'ยืนยันรหัสผ่าน' : 'รหัสผ่าน',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        labelStyle: AppTextStyles.inputText,
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: toggleVisibility,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return isConfirmField ? 'กรุณายืนยันรหัสผ่าน' : 'กรุณากรอกรหัสผ่าน';
        }

        if (!isConfirmField && value.length < 6) {
          return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
        }

        if (isConfirmField &&
            passwordToMatch != null &&
            value != passwordToMatch) {
          return 'รหัสผ่านไม่ตรงกัน';
        }

        return null;
      },
    );
  }
}
