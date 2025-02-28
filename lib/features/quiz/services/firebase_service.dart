import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/quiz_question_model.dart';
import '../services/result_service.dart';

class FirebaseService {
  // เก็บลำดับหัวข้อของแต่ละระดับ CEFR
  static const Map<String, List<String>> cefrTopics = {
    'B1': [
      'daily_life',
      'education',
      'entertainment',
      'environment_and_nature',
      'health_and_fitness',
      'travel_and_tourism',
      'work_and_business',
    ],
    'B2': [
      'cooking_and_culinary_skills',
      'fitness_and_exercise',
      'gardening_and_landscaping',
      'hobbies_and_crafts',
      'home_renovation_and_decor',
      'music_and_performing_arts',
      'outdoor_activities_and_adventures',
      'pet_care_and_animal_welfare',
    ],
    'C1': [
      'creative_writing',
      'cultural_festivals',
      'digital_well_being',
      'event_planning',
      'fashion_trends',
      'interior_decorating',
      'nutrition_and_wellness',
      'urban_living',
    ],
    'C2': [
      'adrenaline_activities',
      'cosmic_discoveries',
      'criminal_investigation',
      'digital_finance',
      'immersive_technologies',
      'legends_and_lore',
      'smart_automation',
    ],
  };

  // ฟังก์ชันโหลดข้อมูลหัวข้อใน Firestore
  static Future<void> preloadTopicLevels() async {
    final topicsCollection =
        FirebaseFirestore.instance.collection('quiz_topic_mapping');

    for (var level in cefrTopics.entries) {
      for (var topic in level.value) {
        final topicDoc = topicsCollection.doc(topic);
        final snapshot = await topicDoc.get();

        // สร้างเอกสารถ้ายังไม่มี
        if (!snapshot.exists) {
          await topicDoc.set({
            'cefrLevel': level.key,
            'topicName': topic,
          });
        }
      }
    }
  }

  /// ฟังก์ชันสำหรับสร้างข้อมูลเริ่มต้นสำหรับผู้ใช้ใหม่
  static Future<void> initializeUserProgress(String userId) async {
    final db = FirebaseFirestore.instance;
    final progressDoc = db
        .collection('users')
        .doc(userId)
        .collection('progress')
        .doc('unlockedTopics');

    // ตรวจสอบว่ามีข้อมูลอยู่แล้วหรือไม่
    final snapshot = await progressDoc.get();
    if (!snapshot.exists) {
      Map<String, dynamic> progressData = {};

      // สร้างข้อมูลเริ่มต้นสำหรับทุกระดับ CEFR
      for (var level in cefrTopics.keys) {
        Map<String, bool> topicStatus = {};
        var topics = cefrTopics[level] ?? [];

        for (var topic in topics) {
          // ถ้าเป็น B1 และเป็นหัวข้อแรก ให้ปลดล็อคเป็น true
          topicStatus[topic] = (level == 'B1' && topic == topics.first);
        }
        progressData[level] = topicStatus;
      }

      // บันทึกข้อมูลลง Firestore
      await progressDoc.set(progressData);
    }
  }

  // ฟังก์ชันจัดการความคืบหน้า (สร้างและอัปเดตข้อมูล)
  static Future<void> manageProgress(
    String userId,
    String cefrLevel,
    String? completedTopic,
    double percentage, // เพิ่มพารามิเตอร์นี้
  ) async {
    final db = FirebaseFirestore.instance;
    final progressDoc = db
        .collection('users')
        .doc(userId)
        .collection('progress')
        .doc('unlockedTopics');

    // ดึงข้อมูลความคืบหน้าจาก Firestore
    final snapshot = await progressDoc.get();

    // ถ้าไม่มีข้อมูล ให้สร้างข้อมูลเริ่มต้นก่อน
    if (!snapshot.exists) {
      await initializeUserProgress(userId);
      return;
    }

    Map<String, dynamic> progressData = snapshot.data() ?? {};

    // สร้างโครงสร้างเริ่มต้นถ้าไม่มีข้อมูล
    if (progressData.isEmpty) {
      progressData = {};
      for (var level in cefrTopics.keys) {
        // สร้าง Map เพื่อเก็บสถานะการปลดล็อคของแต่ละหัวข้อ
        Map<String, bool> topicStatus = {};
        var topics = cefrTopics[level] ?? [];

        for (var topic in topics) {
          // ถ้าเป็น B1 และเป็นหัวข้อแรก ให้ปลดล็อคเป็น true
          if (level == 'B1' && topic == topics.first) {
            topicStatus[topic] = true;
          } else {
            topicStatus[topic] = false;
          }
        }
        progressData[level] = topicStatus;
      }

      // บันทึกข้อมูลลง Firestore
      await progressDoc.set(progressData);
    }

    // ตรวจสอบว่าคะแนนถึงเกณฑ์หรือไม่
    if (percentage >= 60.0 && completedTopic != null) {
      final topics = progressData[cefrLevel] as Map<String, dynamic>? ?? {};
      final topicKeys = cefrTopics[cefrLevel] ?? [];
      final currentIndex = topicKeys.indexOf(completedTopic);

      // ปลดล็อกหัวข้อถัดไปในระดับเดียวกัน
      if (currentIndex != -1 && currentIndex + 1 < topicKeys.length) {
        final nextTopic = topicKeys[currentIndex + 1];
        topics[nextTopic] = true;
      }

      // ตรวจสอบว่าหัวข้อทั้งหมดในระดับปัจจุบันผ่านแล้วหรือไม่
      final allCompleted = topics.values.every((unlocked) => unlocked == true);
      if (allCompleted) {
        final nextLevel = _getNextCEFRLevel(cefrLevel);
        if (nextLevel != null) {
          final nextTopics =
              progressData[nextLevel] as Map<String, dynamic>? ?? {};
          final firstTopic = cefrTopics[nextLevel]?.first;
          if (firstTopic != null) {
            nextTopics[firstTopic] = true;
            progressData[nextLevel] = nextTopics;
          }
        }
      }

      // อัปเดตสถานะกลับไปที่ Firestore
      progressData[cefrLevel] = topics;
      await progressDoc.set(progressData);
    }
  }

  // ฟังก์ชันช่วยดึงระดับ CEFR ถัดไป
  static String? _getNextCEFRLevel(String currentLevel) {
    const levels = ['B1', 'B2', 'C1', 'C2'];
    final currentIndex = levels.indexOf(currentLevel);
    if (currentIndex != -1 && currentIndex + 1 < levels.length) {
      return levels[currentIndex + 1];
    }
    return null;
  }

  // ฟังก์ชันดึงคำถามสำหรับ topic ตาม CEFR Level
  static Future<List<QuizQuestionModel>> getQuestionsForTopic(
      String cefrLevel, String category) async {
    try {
      // 1. ดึงข้อมูลคำที่ตอบผิดบ่อยของผู้ใช้เฉพาะ topic นี้
      final user = FirebaseAuth.instance.currentUser;
      List<String> frequentlyWrongWords = [];
      if (user != null) {
        final wrongWords = await ResultService.getTopWrongWords(
          user.uid,
          limit: 5, // ลดจำนวนลงเหลือ 5 คำที่ตอบผิดบ่อยที่สุด
          topic: category,
        );
        frequentlyWrongWords =
            wrongWords.map((w) => w['word'] as String).toList();
      }

      // 2. ดึงข้อมูลหมวดหมู่ปัจจุบันและหมวดหมู่อื่นๆ
      final categoryDoc = await FirebaseFirestore.instance
          .collection('word_categories')
          .doc(category)
          .get();

      if (!categoryDoc.exists) return [];

      final categoryWords =
          List<String>.from(categoryDoc.data()?['words'] ?? []);

      // ดึงรายการหมวดหมู่อื่นๆ ทั้งหมด
      final otherCategoriesSnap = await FirebaseFirestore.instance
          .collection('word_categories')
          .where(FieldPath.documentId, isNotEqualTo: category)
          .get();

      Map<String, List<String>> otherCategoriesWords = {};
      for (var doc in otherCategoriesSnap.docs) {
        otherCategoriesWords[doc.id] =
            List<String>.from(doc.data()['words'] ?? []);
      }

      // 3. ตรวจสอบว่าคำที่ตอบผิดบ่อยอยู่ใน topic นี้จริงๆ
      frequentlyWrongWords = frequentlyWrongWords
          .where((word) => categoryWords.contains(word))
          .toList();

      // 4. สุ่มเลือกคำศัพท์
      final random = Random();
      final selectedWords = [];

      // เพิ่มคำที่ตอบผิดบ่อยก่อน (สูงสุด 5 คำ)
      final wrongWordsToAdd = frequentlyWrongWords.take(5).toList();
      selectedWords.addAll(wrongWordsToAdd);

      // เติมคำที่เหลือจากหมวดหมู่ปัจจุบัน
      final remainingCount = 30 - selectedWords.length;
      final remainingWords = categoryWords
          .where((w) => !selectedWords.contains(w))
          .toList()
        ..shuffle(random);
      selectedWords.addAll(remainingWords.take(remainingCount));

      // ...ส่วนที่เหลือของโค้ดเดิม (การสร้าง options และ QuizQuestionModel)...
      List<QuizQuestionModel> questions = [];

      for (String wordId in selectedWords) {
        final wordDoc = await FirebaseFirestore.instance
            .collection('words')
            .doc(wordId)
            .get();

        if (!wordDoc.exists) continue;

        final data = wordDoc.data()!;
        final senses = List<Map<String, dynamic>>.from(data['senses'] ?? []);
        if (senses.isEmpty) continue;

        // 5. สร้างตัวเลือก
        List<String> options = [];

        // เพิ่มคำตอบที่ถูก
        options.add(data['mainWord']);

        // เพิ่มคำจากหมวดเดียวกัน 1 คำ
        final sameCategWords = categoryWords.where((w) => w != wordId).toList();
        if (sameCategWords.isNotEmpty) {
          sameCategWords.shuffle(random);
          final word = await _getWordMainWord(sameCategWords.first);
          if (word != null) options.add(word);
        }

        // เพิ่มคำจากหมวดอื่น 2 คำ
        List<String> otherWords = [];
        for (var words in otherCategoriesWords.values) {
          otherWords.addAll(words);
        }
        otherWords.shuffle(random);

        for (int i = 0; i < 2 && i < otherWords.length; i++) {
          final word = await _getWordMainWord(otherWords[i]);
          if (word != null) options.add(word);
        }

        // เติมตัวเลือกให้ครบ 4 ตัวถ้าจำเป็น
        while (options.length < 4 && sameCategWords.isNotEmpty) {
          final word = await _getWordMainWord(sameCategWords.removeLast());
          if (word != null && !options.contains(word)) options.add(word);
        }

        // สลับตำแหน่งตัวเลือก
        options.shuffle(random);

        // Add null check for required fields
        final mainWord = data['mainWord'] as String?;
        final mainPos = data['mainPos'] as String?;

        if (mainWord == null || mainPos == null) continue;

        questions.add(QuizQuestionModel(
          mainWord: mainWord,
          mainPos: mainPos,
          senses: senses,
          cefrLevel: cefrLevel,
          options: options,
          definition: senses[0]['definition'] ?? '',
          thaiWord: '',
        ));
      }

      // สุดท้ายสลับตำแหน่งคำถามทั้งหมด
      questions.shuffle(random);
      return questions;
    } catch (e) {
      debugPrint('Error getting questions: $e');
      return [];
    }
  }

  // Helper function to get mainWord from word document
  static Future<String?> _getWordMainWord(String wordId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('words')
          .doc(wordId)
          .get();
      return doc.data()?['mainWord'] as String?;
    } catch (e) {
      return null;
    }
  }
}
