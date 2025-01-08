import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/quiz_question_model.dart';

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
    final topicsCollection = FirebaseFirestore.instance.collection('quiz_topic_mapping');

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

  // ฟังก์ชันจัดการความคืบหน้า (สร้างและอัปเดตข้อมูล)
  static Future<void> manageProgress(
      String userId,
      String cefrLevel,
      String? completedTopic,
      double percentage, // เพิ่มพารามิเตอร์นี้
      ) async {
    final db = FirebaseFirestore.instance;
    final progressDoc = db.collection('users').doc(userId).collection('progress').doc('unlockedTopics');

    // ดึงข้อมูลความคืบหน้าจาก Firestore
    final snapshot = await progressDoc.get();
    Map<String, dynamic> progressData = snapshot.data() ?? {};

    // สร้างโครงสร้างเริ่มต้นถ้าไม่มีข้อมูล
    if (progressData.isEmpty) {
      progressData = cefrTopics.map((level, topics) {
        final initialUnlock = level == 'B1' ? {'daily_life': true} : {};
        return MapEntry(level, {
          for (var topic in topics) topic: initialUnlock[topic] ?? false,
        });
      });
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
          final nextTopics = progressData[nextLevel] as Map<String, dynamic>? ?? {};
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
  static Future<List<QuizQuestionModel>> getQuestionsForTopic(String cefrLevel, String topic) async {
    List<QuizQuestionModel> questions = [];
    final questionTypes = ['multiple_choice', 'drag_and_drop', 'matching'];

    for (var qType in questionTypes) {
      final colRef = FirebaseFirestore.instance
          .collection('quiz_cefr_levels')
          .doc(cefrLevel)
          .collection('topics')
          .doc(topic)
          .collection(qType);

      final snapshot = await colRef.get();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final questionModel = _mapToQuizQuestionModel(qType, data);
        if (questionModel != null) {
          questions.add(questionModel);
        }
      }
    }
    return questions;
  }

  // ฟังก์ชันแมปข้อมูลจาก Firestore เป็น QuizQuestionModel
  static QuizQuestionModel? _mapToQuizQuestionModel(String qType, Map<String, dynamic> data) {
    switch (qType) {
      case 'multiple_choice':
        return QuizQuestionModel(
          type: QuestionType.multipleChoice,
          question: data['question'] as String? ?? '',
          options: (data['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
          correctAnswer: data['correctAnswer'] as String? ?? '',
          partOfSpeech: data['partOfSpeech'] as String? ?? '',
          exampleSentence: data['exampleSentence'] as String? ?? '',
          translatedSentence: data['translatedSentence'] as String? ?? '',
        );
      case 'drag_and_drop':
        return QuizQuestionModel(
          type: QuestionType.dragAndDrop,
          question: data['question'] as String? ?? '',
          draggableItems: (data['draggableItems'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
          targets: (data['targets'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
          correctMatches: (data['correctMatches'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v.toString())) ??
              {},
        );
      case 'matching':
        return QuizQuestionModel(
          type: QuestionType.matching,
          question: data['question'] as String? ?? '',
          leftItems: (data['leftItems'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
          rightItems: (data['rightItems'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
          correctMatches: (data['correctMatches'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v.toString())) ??
              {},
        );
      default:
        return null;
    }
  }
}
