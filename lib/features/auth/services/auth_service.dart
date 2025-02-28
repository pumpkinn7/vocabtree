import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:vocabtree/features/quiz/services/firebase_service.dart';

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

  static Future<void> handlePostSignIn(User user) async {
    // สร้างข้อมูลเริ่มต้นสำหรับผู้ใช้
    await FirebaseService.initializeUserProgress(user.uid);
  }

  Future<bool> deleteUserAccount(String userId) async {
    try {
      // 1. ลบข้อมูลความคืบหน้าทั้งหมด
      await _deleteUserProgress(userId);
      
      // 2. ลบประวัติการทำ Quiz
      await _deleteQuizHistory(userId);
      
      // 3. ลบข้อมูล Vocabulary Progress
      await _deleteVocabularyProgress(userId);
      
      // 4. ลบข้อมูล Profile
      await _firestore.collection('profiles').doc(userId).delete();
      
      // 5. ลบข้อมูล User
      await _firestore.collection('users').doc(userId).delete();
      
      // 6. ลบบัญชี Firebase Auth
      await _auth.currentUser?.delete();
      
      // 7. ทำการ Sign Out หลังจากลบบัญชีสำเร็จ
      await signOut();
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting user account: $e');
      }
      return false;
    }
  }

  Future<void> _deleteUserProgress(String userId) async {
    // ลบข้อมูล progress ทั้งหมด
    final progressRef = _firestore.collection('users').doc(userId).collection('progress');
    final progressDocs = await progressRef.get();
    
    final batch = _firestore.batch();
    for (var doc in progressDocs.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> _deleteQuizHistory(String userId) async {
    // ลบประวัติการทำ Quiz
    final quizRef = _firestore.collection('users').doc(userId).collection('quizHistory');
    final quizDocs = await quizRef.get();
    
    final batch = _firestore.batch();
    for (var doc in quizDocs.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    // ลบสถิติคำศัพท์
    final wordStatsRef = _firestore.collection('users').doc(userId).collection('wordStats');
    final wordStatsDocs = await wordStatsRef.get();
    
    final statsBatch = _firestore.batch();
    for (var doc in wordStatsDocs.docs) {
      statsBatch.delete(doc.reference);
    }
    await statsBatch.commit();
  }

  Future<void> _deleteVocabularyProgress(String userId) async {
    // ลบข้อมูล vocabulary progress
    final levels = ['B1', 'B2', 'C1', 'C2'];
    
    for (var level in levels) {
      final levelRef = _firestore.collection('users').doc(userId).collection(level);
      final levelDocs = await levelRef.get();
      
      for (var topicDoc in levelDocs.docs) {
        // ลบ subcollection vocabularies
        final vocabRef = topicDoc.reference.collection('vocabularies');
        final vocabDocs = await vocabRef.get();
        
        final batch = _firestore.batch();
        for (var doc in vocabDocs.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        
        // ลบ topic document
        await topicDoc.reference.delete();
      }
    }

    // ลบข้อมูล vocabulary_progress
    final vocabProgressRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('vocabulary_progress');
    final vocabProgressDocs = await vocabProgressRef.get();
    
    final batch = _firestore.batch();
    for (var doc in vocabProgressDocs.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
