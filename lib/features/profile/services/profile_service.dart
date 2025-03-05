import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vocabtree/features/auth/services/auth_service.dart';
import 'package:vocabtree/features/profile/models/profile_model.dart';

class ProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthService _authService = AuthService();

  Future<ProfileModel> loadUserProfile() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final profileDoc =
          await _firestore.collection('profiles').doc(user.uid).get();

      return ProfileModel.fromFirestore(
          userDoc.data(), profileDoc.data(), user.email);
    } else {
      throw Exception('ผู้ใช้ยังไม่ได้เข้าสู่ระบบ');
    }
  }

  Future<void> toggleDisplayMode(bool isDarkModeEnabled) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('profiles').doc(user.uid).update({
        'settings.displayMode': isDarkModeEnabled ? 'dark' : 'light',
      });
    } else {
      throw Exception('ผู้ใช้ยังไม่ได้เข้าสู่ระบบ');
    }
  }

  Future<String> uploadProfileImage(File imageFile) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final fileName = '${user.uid}.jpg';
      final uploadTask =
          _storage.ref('profile_images/$fileName').putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({'profileImageUrl': downloadUrl});

      return downloadUrl;
    } else {
      throw Exception('ผู้ใช้ยังไม่ได้เข้าสู่ระบบ');
    }
  }

  Future<bool> reauthenticateUser(String password) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: _auth.currentUser!.email!,
        password: password,
      );
      await _auth.currentUser!.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteUserAccount(String userId) async {
    return await _authService.deleteUserAccount(userId);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
