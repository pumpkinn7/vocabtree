import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class ManageAccountDialog extends StatelessWidget {
  final VoidCallback onResetPassword;
  final VoidCallback onDeleteAccount;

  const ManageAccountDialog({
    super.key,
    required this.onResetPassword,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('จัดการบัญชี', style: AppTextStyles.headline),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/tree_6977598.png',
            width: 35,
            height: 35,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onResetPassword();
            },
            child: Text('ฉันลืมรหัสผ่าน', style: AppTextStyles.label),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDeleteAccount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('ลบบัญชีผู้ใช้งาน', style: AppTextStyles.label),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text('ปิด', style: AppTextStyles.label),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
