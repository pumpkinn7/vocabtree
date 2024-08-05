import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocabtree/pages/login/login_screen.dart';
import 'package:vocabtree/pages/otp/otp_verification_screen.dart';
import 'package:vocabtree/pages/register/account_success_screen.dart';
import 'package:vocabtree/pages/register/register_screen.dart';
import 'package:vocabtree/pages/reset_password/forget_password_screen.dart';
import 'package:vocabtree/theme/theme_provider.dart';
import 'package:vocabtree/widgets/bottom_navbar.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final themeMode = await _getInitialThemeMode();
  runApp(MyApp(initialThemeMode: themeMode));
}

Future<ThemeMode> _getInitialThemeMode() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    DocumentSnapshot<Map<String, dynamic>> profileSnapshot =
        await FirebaseFirestore.instance
            .collection('profiles')
            .doc(user.uid)
            .get();
    if (profileSnapshot.exists) {
      String displayMode =
          profileSnapshot.data()?['settings']['displayMode'] ?? 'light';
      return displayMode == 'dark' ? ThemeMode.dark : ThemeMode.light;
    }
  }
  return ThemeMode.light;
}

class MyApp extends StatelessWidget {
  final ThemeMode initialThemeMode;

  const MyApp({super.key, required this.initialThemeMode});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(initialThemeMode),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            themeMode: themeProvider.themeMode,
            theme: ThemeData.light(), // ธีมกลางวัน
            darkTheme: ThemeData.dark(), // ธีมกลางคืน
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
                    user: FirebaseAuth
                        .instance.currentUser!, // ปรับตามความต้องการ
                    profileImageUrl: '', // ปรับตามความต้องการ
                  ),
              '/account-success': (context) => const AccountSuccessScreen(),
              '/login': (context) => const LoginScreen(),
              '/home': (context) =>
                  const BottomNavBar(), // เปลี่ยนหน้า home ให้ใช้ BottomNavBar
            },
          );
        },
      ),
    );
  }
}
