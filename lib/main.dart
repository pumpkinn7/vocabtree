import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vocabtree/pages/account_success_screen.dart';
import 'package:vocabtree/pages/forget_password_screen.dart';
import 'package:vocabtree/pages/login_screen.dart';
import 'package:vocabtree/pages/otp_verification_screen.dart';
import 'package:vocabtree/pages/register_screen.dart';
import 'package:vocabtree/pages/reset_password_screen.dart';
import 'package:vocabtree/pages/reset_password_success_screen.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/reset-password': (context) => const ForgetPasswordScreen(),
        '/register': (context) => const RegisterScreen(),
        '/otp-verification': (context) => const OTPVerificationScreen(),
        '/reset-password-form': (context) => const ResetPasswordScreen(),
        '/reset-password-success': (context) =>
            const ResetPasswordSuccessScreen(),
        '/account-success': (context) =>
            const AccountSuccessScreen(), // เส้นทางสำหรับหน้า AccountSuccessScreen
        '/login': (context) => const LoginScreen(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Sarabun', // ตั้งค่าฟอนต์ที่ต้องการใช้ที่นี่
      ),
    );
  }
}
