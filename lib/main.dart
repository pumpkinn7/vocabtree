import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vocabtree/pages/account/account_success_screen.dart';
import 'package:vocabtree/pages/login/login_screen.dart';
import 'package:vocabtree/pages/otp/otp_verification_screen.dart'; // import OTPVerificationScreen
import 'package:vocabtree/pages/register/register_screen.dart';
import 'package:vocabtree/pages/reset_password/forget_password_screen.dart';
import 'package:vocabtree/pages/reset_password/reset_password_screen.dart';
import 'package:vocabtree/pages/reset_password/reset_password_success_screen.dart';

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
        '/otp-verification': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return OTPVerificationScreen(
            user: args['user'],
            profileImageUrl: args['profileImageUrl'],
          );
        },
        '/reset-password-form': (context) => const ResetPasswordScreen(),
        '/reset-password-success': (context) =>
            const ResetPasswordSuccessScreen(),
        '/account-success': (context) => const AccountSuccessScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
