import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback toggleVisibility;
  final bool isConfirmField;
  final String? passwordToMatch;
  // เพิ่ม controller ของอีกฟิลด์หนึ่งเพื่อเข้าถึงค่าปัจจุบัน
  final TextEditingController? otherPasswordController;

  const PasswordField({
    super.key,
    required this.controller,
    required this.obscureText,
    required this.toggleVisibility,
    this.isConfirmField = false,
    this.passwordToMatch,
    this.otherPasswordController,
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

        // เช็คโดยใช้ค่าปัจจุบันจาก controller
        if (isConfirmField && otherPasswordController != null) {
          if (value != otherPasswordController!.text) {
            return 'รหัสผ่านไม่ตรงกัน';
          }
        }
        // คงไว้สำหรับความเข้ากันได้กับโค้ดเดิม
        else if (isConfirmField &&
            passwordToMatch != null &&
            value != passwordToMatch) {
          return 'รหัสผ่านไม่ตรงกัน';
        }

        return null;
      },
    );
  }
}
