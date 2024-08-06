import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthResult {
  final bool success;
  final String? errorMessage;
  final User? user;

  AuthResult({required this.success, this.errorMessage, this.user});
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> isUsernameTaken(String username) async {
    final QuerySnapshot result = await _firestore
        .collection('profiles')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return result.docs.isNotEmpty;
  }

  Future<bool> isEmailRegistered(String email) async {
    final QuerySnapshot result = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    return result.docs.isNotEmpty;
  }

  Future<AuthResult> registerUser({
    required String username,
    required String email,
    required String password,
    String? profileImageUrl,
  }) async {
    try {
      if (await isUsernameTaken(username)) {
        return AuthResult(
            success: false,
            errorMessage: 'ชื่อผู้ใช้งานนี้ถูกใช้ไปแล้ว กรุณาใช้ชื่ออื่น');
      }
      if (await isEmailRegistered(email)) {
        return AuthResult(
            success: false,
            errorMessage:
                'อีเมลนี้ถูกใช้งานแล้ว คุณสามารถรีเซตรหัสผ่าน หรือใช้เมลใหม่แทน');
      }

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        await _createUserDocument(user.uid, username, email, profileImageUrl);
        await user.sendEmailVerification();
        return AuthResult(success: true, user: user);
      } else {
        return AuthResult(
            success: false, errorMessage: 'ไม่สามารถสร้างบัญชีผู้ใช้ได้');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in registerUser: $e');
      }
      return AuthResult(success: false, errorMessage: 'เกิดข้อผิดพลาด: $e');
    }
  }

  Future<void> _createUserDocument(String userId, String username, String email,
      String? profileImageUrl) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'email': email,
        'profileImageUrl': profileImageUrl ?? '',
        'username': username,
      });

      await _firestore.collection('profiles').doc(userId).set({
        'username': username,
        'userId': userId,
        'friends': [],
        'achievements': [],
        'settings': {'displayMode': 'light'},
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('User document created with profileImageUrl: $profileImageUrl');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating user document: $e');
      }
      rethrow;
    }
  }

  Future<AuthResult> verifyEmail(User user) async {
    try {
      await user.reload();
      user = _auth.currentUser!;
      if (user.emailVerified) {
        return AuthResult(success: true, user: user);
      } else {
        return AuthResult(
            success: false, errorMessage: 'อีเมลยังไม่ได้รับการยืนยัน');
      }
    } catch (e) {
      return AuthResult(
          success: false, errorMessage: 'เกิดข้อผิดพลาดในการตรวจสอบอีเมล');
    }
  }

  Future<AuthResult> resendVerificationEmail(User user) async {
    try {
      await user.sendEmailVerification();
      return AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, errorMessage: _getErrorMessage(e));
    } catch (e) {
      return AuthResult(
          success: false, errorMessage: 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ');
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'อีเมลนี้ถูกใช้งานแล้ว คุณสามารถรีเซตรหัสผ่าน หรือใช้เมลใหม่แทน';
      case 'invalid-email':
        return 'อีเมลไม่ถูกต้อง';
      case 'operation-not-allowed':
        return 'การดำเนินการนี้ไม่ได้รับอนุญาต';
      case 'weak-password':
        return 'รหัสผ่านไม่ปลอดภัยเพียงพอ';
      case 'too-many-requests':
        return 'มีการร้องขอมากเกินไป โปรดลองอีกครั้งในภายหลัง';
      default:
        return 'เกิดข้อผิดพลาด: ${e.message}';
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
