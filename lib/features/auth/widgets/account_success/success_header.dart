import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class SuccessHeader extends StatelessWidget {
  const SuccessHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'สร้างบัญชีสำเร็จ',
          style: AppTextStyles.headline,
        ),
        const SizedBox(height: 10),
        Text(
          'สนุกกับการเรียนรู้คำศัพท์ใหม่\nและ แบบทดสอบหลากหลาย',
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
