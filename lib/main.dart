import 'dart:async';

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

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // จัดการข้อผิดพลาดที่เกิดขึ้นใน Flutter framework
    if (kDebugMode) {
      print('Flutter Error: ${details.exceptionAsString()}');
      print('Stack Trace: ${details.stack}');
    }
  };

  runZonedGuarded(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    ThemeMode themeMode = await _getInitialThemeMode();

    runApp(MyApp(initialThemeMode: themeMode));
  }, (error, stackTrace) {
    // จัดการข้อผิดพลาดที่ไม่ได้ถูกจับ
    if (kDebugMode) {
      print('Uncaught Error: $error');
      print('Stack Trace: $stackTrace');
    }
  });
}

Future<ThemeMode> _getInitialThemeMode() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> profileSnapshot =
          await FirebaseFirestore.instance
              .collection('profiles')
              .doc(user.uid)
              .get();

      if (profileSnapshot.exists) {
        Map<String, dynamic>? data = profileSnapshot.data();
        Map<String, dynamic>? settings =
            data?['settings'] as Map<String, dynamic>?;

        if (settings != null) {
          String? displayMode = settings['displayMode'] as String?;
          if (displayMode == 'dark') {
            return ThemeMode.dark;
          } else if (displayMode == 'light') {
            return ThemeMode.light;
          }
        }
      }
    }
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print('Error getting initial theme mode: $e');
      print('Stack Trace: $stackTrace');
    }
  }
  return ThemeMode.system;
}

class MyApp extends StatefulWidget {
  final ThemeMode initialThemeMode;

  const MyApp({super.key, required this.initialThemeMode});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (kDebugMode) {
      print('App initState');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (kDebugMode) {
      print('App disposed');
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kDebugMode) {
      print('AppLifecycleState changed to $state');
    }
    if (state == AppLifecycleState.resumed) {
      if (kDebugMode) {
        print('App resumed');
      }
      // คุณสามารถเพิ่มโค้ดที่ต้องการให้ทำงานเมื่อแอปกลับมาได้ที่นี่
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(widget.initialThemeMode),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            theme: AppTextStyles.lightTheme,
            darkTheme: AppTextStyles.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const RootWidget(),
            routes: {
              '/reset-password': (context) => const ResetPasswordScreen(),
              '/register': (context) => const RegisterScreen(),
              '/otp-verification': (context) {
                User? currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser != null) {
                  return OTPVerificationScreen(
                    email: '',
                    password: '',
                    username: '',
                    profileImageFile: null,
                    user: currentUser,
                    profileImageUrl: '',
                  );
                } else {
                  return const LoginScreen();
                }
              },
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

class RootWidget extends StatelessWidget {
  const RootWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return const BottomNavBar();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
