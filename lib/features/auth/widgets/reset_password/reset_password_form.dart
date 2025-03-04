import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import 'package:vocabtree/core/utils/responsive_helper.dart';

class ResetPasswordForm extends StatelessWidget {
  final TextEditingController emailController;
  final VoidCallback onResetPassword;

  const ResetPasswordForm({
    super.key,
    required this.emailController,
    required this.onResetPassword,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = ResponsiveHelper.getScreenWidth(context);
    final buttonHeight = screenWidth > 600 ? 56.0 : 48.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            labelText: 'อีเมลที่ท่านเชื่อมโยงบัญชี',
            labelStyle: AppTextStyles.inputText,
            contentPadding: EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 15,
            ),
          ),
        ),
        SizedBox(height: ResponsiveHelper.getVerticalSpacing(context) * 0.4),
        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: onResetPassword,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Text(
              'ส่งลิงก์รีเซ็ตรหัสผ่าน',
              style: AppTextStyles.label,
            ),
          ),
        ),
      ],
    );
  }
}
