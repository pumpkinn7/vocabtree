import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class VerificationButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;

  const VerificationButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        // ปรับ style ให้เหมือนกับปุ่มใน LoginForm
        style: ElevatedButton.styleFrom(
            // ลบ padding และ shape ที่มีอยู่เดิม เพื่อใช้ตามค่าเริ่มต้นเหมือน LoginForm
            ),
        child: Text(buttonText, style: AppTextStyles.label),
      ),
    );
  }
}
