import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import 'package:vocabtree/core/theme/theme_provider.dart';
import 'package:vocabtree/core/widgets/bottom_navbar.dart';
import 'package:vocabtree/features/auth/screens/account_success_screen.dart';
import 'package:vocabtree/features/auth/screens/forget_password_screen.dart';
import 'package:vocabtree/features/auth/screens/login_screen.dart';
import 'package:vocabtree/features/auth/screens/otp_verification_screen.dart';
import 'package:vocabtree/features/auth/screens/register_screen.dart';

import 'core/config/firebase_options.dart';

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
    try {
      DocumentSnapshot<Map<String, dynamic>> profileSnapshot =
          await FirebaseFirestore.instance
              .collection('profiles')
              .doc(user.uid)
              .get();
      if (profileSnapshot.exists) {
        String displayMode = profileSnapshot.data()?['settings']['displayMode'];
        if (displayMode == 'dark') {
          return ThemeMode.dark;
        } else if (displayMode == 'light') {
          return ThemeMode.light;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting initial theme mode: $e');
      }
    }
  }
  return ThemeMode.system;
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
            theme: AppTextStyles.lightTheme,
            darkTheme: AppTextStyles.darkTheme,
            initialRoute: '/',
            routes: {
              '/': (context) => const LoginScreen(),
              '/reset-password': (context) => const ResetPasswordScreen(),
              '/register': (context) => const RegisterScreen(),
              '/otp-verification': (context) => OTPVerificationScreen(
                    email: '',
                    password: '',
                    username: '',
                    profileImageFile: null,
                    user: FirebaseAuth.instance.currentUser!,
                    profileImageUrl: '',
                  ),
              '/account-success': (context) => const AccountSuccessScreen(),
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const BottomNavBar(),
            },
          );
        },
      ),
    );
  }
}
