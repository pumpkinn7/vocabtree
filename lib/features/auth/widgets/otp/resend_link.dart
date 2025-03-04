import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class ResendLink extends StatelessWidget {
  final VoidCallback onResend;

  const ResendLink({
    super.key,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: 'ฉันยังไม่ได้รับรหัสยืนยัน? ',
        style: AppTextStyles.label,
        children: [
          TextSpan(
            text: 'ส่งอีกครั้ง',
            style: AppTextStyles.label.copyWith(color: Colors.orange),
            recognizer: TapGestureRecognizer()..onTap = onResend,
          ),
        ],
      ),
    );
  }
}
