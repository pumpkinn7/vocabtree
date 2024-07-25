import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vocabtree/pages/home/home_screen.dart';
import 'package:vocabtree/pages/login/login_screen.dart';
import 'package:vocabtree/pages/otp/otp_verification_screen.dart';
import 'package:vocabtree/pages/register/account_success_screen.dart';
import 'package:vocabtree/pages/register/register_screen.dart';
import 'package:vocabtree/pages/reset_password/forget_password_screen.dart';

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
        '/otp-verification': (context) => OTPVerificationScreen(
              email: '',
              password: '',
              username: '',
              profileImageFile: null,
              user: FirebaseAuth.instance.currentUser!, // ปรับตามความต้องการ
              profileImageUrl: '', // ปรับตามความต้องการ
            ),
        '/account-success': (context) => const AccountSuccessScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
