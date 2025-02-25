import 'package:flutter/foundation.dart';

/// Simple logger utility for the application
///
/// This centralizes logging and allows easy switching between
/// different logging behaviors in production vs development
class AppLogger {
  /// Log a debug message
  static void d(String tag, String message) {
    if (kDebugMode) {
      print('DEBUG [$tag]: $message');
    }
  }

  /// Log an info message
  static void i(String tag, String message) {
    if (kDebugMode) {
      print('INFO [$tag]: $message');
    }
  }

  /// Log an error message
  static void e(String tag, String message,
      [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('ERROR [$tag]: $message');
      if (error != null) {
        print('ERROR DETAILS: $error');
      }
      if (stackTrace != null) {
        print('STACK TRACE: $stackTrace');
      }
    }

    // In production, you might want to send errors to a service like Firebase Crashlytics
    // For example:
    // FirebaseCrashlytics.instance.recordError(error, stackTrace, reason: message);
  }
}
