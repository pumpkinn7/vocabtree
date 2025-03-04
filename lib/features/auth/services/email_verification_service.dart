import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailVerificationService {
  final BuildContext context;

  EmailVerificationService(this.context);

  Future<void> verifyEmail(
      User user, String username, String email, String profileImageUrl) async {
    try {
      await user.reload();
      User? refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser != null && refreshedUser.emailVerified) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(refreshedUser.uid)
            .set({
          'username': username,
          'email': email,
          'profileImageUrl': profileImageUrl,
          'createdAt': FieldValue.serverTimestamp(), // เพิ่มเวลาที่สร้างบัญชี
        });

        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/account-success',
            (Route<dynamic> route) => false,
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('กรุณายืนยันอีเมลของคุณก่อนดำเนินการต่อ'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> resendVerificationEmail(User user) async {
    try {
      await user.sendEmailVerification();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ส่งลิงก์ยืนยันอีเมลอีกครั้งเรียบร้อยแล้ว'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('กรุณารอสักครู่ก่อนที่จะส่งอีกครั้ง'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
