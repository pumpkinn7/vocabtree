import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import 'package:vocabtree/core/utils/responsive_helper.dart';

class ResetPasswordHeader extends StatelessWidget {
  const ResetPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageSize = screenHeight * 0.15; // 15% of screen height

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveHelper.getVerticalSpacing(context) * 0.3,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/Voodoo.png',
            height: imageSize,
            fit: BoxFit.contain,
          ),
          SizedBox(height: ResponsiveHelper.getVerticalSpacing(context) * 0.4),
          Text(
            'รีเซ็ตรหัสผ่าน',
            style: AppTextStyles.headline,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveHelper.getVerticalSpacing(context) * 0.2),
          Text(
            'กรุณากรอกที่อยู่อีเมลที่เชื่อมโยงกับบัญชีของคุณเพื่อรับลิงก์รีเซ็ตรหัสผ่าน',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
