import 'package:flutter/material.dart';
import 'package:vocabtree/theme/text_styles.dart';

class AccountSuccessScreen extends StatelessWidget {
  const AccountSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              Image.asset(
                'assets/icons/Successmark.png',
                height: 150,
              ),
              const SizedBox(height: 20),
              const Text(
                'สร้างบัญชีสำเร็จ',
                style: AppTextStyles.headline,
              ),
              const SizedBox(height: 10),
              Text(
                'สนุกกับการเรียนรู้คำศัพท์ใหม่\nและ แบบทดสอบหลากหลาย',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'ดำเนินการเข้าสู่ระบบ',
                    style: AppTextStyles.label,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
