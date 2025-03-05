import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class ManageAccountDialog extends StatelessWidget {
  final VoidCallback onResetPasswordPressed;
  final VoidCallback onDeleteAccountPressed;

  const ManageAccountDialog({
    super.key,
    required this.onResetPasswordPressed,
    required this.onDeleteAccountPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: IntrinsicHeight(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ส่วนหัว dialog
                const Text(
                  'จัดการบัญชี',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                // รูปภาพ
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/images/tree_6977598.png',
                      width: 60,
                      height: 60,
                    ),
                  ),
                ),

                // ปุ่มลืมรหัสผ่าน
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: _buildButton('ฉันลืมรหัสผ่าน',
                        onPressed: onResetPasswordPressed),
                  ),
                ),

                // ปุ่มลบบัญชี
                SizedBox(
                  width: double.infinity,
                  child: _buildRedButton('ลบบัญชีผู้ใช้งาน',
                      onPressed: onDeleteAccountPressed),
                ),

                // ปุ่มปิด - อยู่ด้านล่างขวา
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('ปิด'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String label, {required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.grey),
        ),
      ),
      onPressed: onPressed,
      child: Text(label, style: AppTextStyles.inputText),
    );
  }

  Widget _buildRedButton(String label, {required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.red),
        ),
      ),
      onPressed: onPressed,
      child: Text(label, style: AppTextStyles.inputText),
    );
  }
}
