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
        // สร้างข้อมูลผู้ใช้
        await FirebaseFirestore.instance
            .collection('users')
            .doc(refreshedUser.uid)
            .set({
          'username': username,
          'email': email,
          'profileImageUrl': profileImageUrl,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // สร้างข้อมูลความคืบหน้าเริ่มต้นและปลดล็อคหัวข้อแรก
        await _initializeUserProgress(refreshedUser.uid);

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

  Future<void> _initializeUserProgress(String userId) async {
    final progressDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('progress')
        .doc('unlockedTopics');

    // สร้างข้อมูลเริ่มต้นสำหรับทุกระดับ CEFR และหัวข้อ
    final Map<String, Map<String, bool>> progressData = {
      'B1': {
        'daily_life': true,
        'education': false,
        'entertainment': false,
        'environment_and_nature': false,
        'food_and_dining': false,
        'health_and_medical': false,
        'technology': false,
        'travel_and_tourism': false,
      },
      'B2': {
        'cooking_and_culinary_skills': false,
        'fitness_and_exercise': false,
        'gardening_and_landscaping': false,
        'hobbies_and_crafts': false,
        'home_renovation_and_decor': false,
        'music_and_performing_arts': false,
        'outdoor_activities_and_adventures': false,
        'pet_care_and_animal_welfare': false,
      },
      'C1': {
        'creative_writing': false,
        'cultural_festivals': false,
        'digital_well_being': false,
        'event_planning': false,
        'fashion_trends': false,
        'interior_decorating': false,
        'nutrition_and_wellness': false,
        'urban_living': false,
      },
      'C2': {
        'adrenaline_activities': false,
        'cosmic_discoveries': false,
        'criminal_investigation': false,
        'digital_finance': false,
        'immersive_technologies': false,
        'legends_and_lore': false,
        'smart_automation': false,
      }
    };

    // บันทึกข้อมูลลง Firestore
    await progressDoc.set(progressData);
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
