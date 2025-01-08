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

import '../features/quiz/services/firebase_service.dart'; // Import FirebaseService
import 'core/config/firebase_options.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      if (kDebugMode) {
        print('Flutter Error: ${details.exceptionAsString()}');
        print('Stack Trace: ${details.stack}');
      }
    };

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    ThemeMode themeMode = await _getInitialThemeMode();

    // โหลดข้อมูลเริ่มต้น
    await FirebaseService.preloadTopicLevels(); // โหลดหัวข้อและระดับ CEFR
    await _initializeUserProgress(); // สร้างสถานะผู้ใช้ถ้าไม่มีข้อมูล

    runApp(MyApp(initialThemeMode: themeMode));
  }, (error, stackTrace) {
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

Future<void> _initializeUserProgress() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final userId = user.uid;
  final progressDoc = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('progress')
      .doc('unlockedTopics');

  final snapshot = await progressDoc.get();
  if (!snapshot.exists) {
    // สร้างสถานะปลดล็อกเริ่มต้น
    await progressDoc.set(
      FirebaseService.cefrTopics.map((level, topics) {
        final initialUnlock = level == 'B1' ? {'daily_life': true} : {};
        return MapEntry(level, {
          for (var topic in topics) topic: initialUnlock[topic] ?? false,
        });
      }),
    );
  }
}
class MyApp extends StatefulWidget {
  final ThemeMode initialThemeMode;

  const MyApp({super.key, required this.initialThemeMode});

  @override
  MyAppState createState() => MyAppState(); // เปลี่ยนจาก _MyAppState เป็น MyAppState
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
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
