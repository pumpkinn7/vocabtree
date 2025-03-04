import 'package:flutter/material.dart';
import 'package:vocabtree/core/utils/responsive_helper.dart';
import 'package:vocabtree/features/auth/widgets/account_success/login_button.dart';
import 'package:vocabtree/features/auth/widgets/account_success/success_header.dart';
import 'package:vocabtree/features/auth/widgets/account_success/success_image.dart';

class SuccessContent extends StatelessWidget {
  final VoidCallback onLoginPressed;

  const SuccessContent({super.key, required this.onLoginPressed});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isLargeScreen = screenWidth > 600;
        final imageHeight = isLargeScreen ? 160.0 : 130.0;

        // เพิ่มระยะห่างด้านบนโดยขึ้นอยู่กับขนาดหน้าจอ
        final double topSpacing = isLargeScreen ? 60.0 : 40.0;

        return Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: topSpacing), // ใช้ค่าคงที่แทนการคำนวณ responsive
              SuccessImage(height: imageHeight),
              SizedBox(
                  height: ResponsiveHelper.getVerticalSpacing(context) * 0.15),
              const SuccessHeader(),
              SizedBox(
                  height: ResponsiveHelper.getVerticalSpacing(context) * 0.25),
              LoginButton(onPressed: onLoginPressed),
            ],
          ),
        );
      },
    );
  }
}
