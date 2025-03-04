import 'package:flutter/material.dart';
import 'package:vocabtree/core/utils/responsive_helper.dart';
import 'package:vocabtree/features/auth/widgets/account_success/success_content.dart';

class AccountSuccessScreen extends StatelessWidget {
  const AccountSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // คำนวณขนาดอุปกรณ์สำหรับการปรับ padding
    final double screenHeight = MediaQuery.of(context).size.height;
    final double topPadding = screenHeight * 0.08; // 8% of screen height

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            top: topPadding, // ใช้ค่า padding ด้านบนตามที่คำนวณไว้
            left: ResponsiveHelper.getScreenWidth(context) * 0.05,
            right: ResponsiveHelper.getScreenWidth(context) * 0.05,
          ),
          child: SingleChildScrollView(
            child: SuccessContent(
              onLoginPressed: () => Navigator.pushNamed(context, '/login'),
            ),
          ),
        ),
      ),
    );
  }
}
