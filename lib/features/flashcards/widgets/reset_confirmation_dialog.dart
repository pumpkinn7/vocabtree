import 'package:flutter/material.dart';
import '../../../core/theme/text_styles.dart';

class ResetConfirmationDialog extends StatelessWidget {
  const ResetConfirmationDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const ResetConfirmationDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(
        'ยืนยันการรีเซ็ต',
        style: AppTextStyles.subtitle,
      ),
      content: Text(
        'สถานะของคำศัพท์ทั้งหมดจะถูกล้างและเริ่มต้นใหม่อีกครั้ง',
        style: AppTextStyles.body,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.onSurface, // สีปกติเหมือนข้อความทั่วไป
          ),
          child: Text(
            'ยกเลิก',
            style: AppTextStyles.body, // ใช้สไตล์เดียวกับข้อความทั่วไป
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary, // ใช้ primaryColor
            foregroundColor: colorScheme.onPrimary, // สีข้อความบนพื้นสีหลัก
            elevation: 1,
          ),
          child: Text(
            'ยืนยัน',
            style: AppTextStyles.buttonText,
          ),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: colorScheme.surface,
      elevation: 4,
    );
  }
}
