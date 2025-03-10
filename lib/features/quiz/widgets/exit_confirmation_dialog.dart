import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class ExitConfirmationDialog extends StatelessWidget {
  const ExitConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'ยืนยันการออก',
        style: AppTextStyles.subtitle,
      ),
      content: Text(
        'คุณยังทำ Quiz ไม่เสร็จ ต้องการออกหรือไม่? คะแนนจะไม่ถูกบันทึก',
        style: AppTextStyles.body,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'ยกเลิก',
            style: AppTextStyles.buttonText.copyWith(color: Colors.grey),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            'ออก',
            style: AppTextStyles.buttonText.copyWith(color: Colors.red),
          ),
        ),
      ],
    );
  }
}
