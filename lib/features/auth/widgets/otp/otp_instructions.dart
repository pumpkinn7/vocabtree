import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class OtpInstructions extends StatelessWidget {
  const OtpInstructions({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        'เราได้ส่ง Link ยืนยัน OTP\nไปที่อีเมลของคุณเรียบร้อยแล้ว กดยืนยันเพื่อเข้าใช้งาน',
        textAlign: TextAlign.center,
        style: AppTextStyles.label,
      ),
    );
  }
}
