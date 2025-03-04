import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class EmailField extends StatelessWidget {
  final TextEditingController controller;

  const EmailField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
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
}
