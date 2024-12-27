import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/quiz_question_model.dart';

class FirebaseService {
  // เก็บ Mapping ระหว่าง topic และ CEFR Level ใน Cache
  static final Map<String, String> _topicLevelCache = {};

  // ฟังก์ชันดึง CEFR Level แบบ Synchronous จาก Cache
  static String getCEFRLevelForTopicSync(String topic) {
    return _topicLevelCache[topic] ?? 'B1';
  }

  // ฟังก์ชัน preload ข้อมูล topic กับ CEFR Level
  static Future<void> preloadTopicLevels() async {
    final snap = await FirebaseFirestore.instance
        .collection('quiz_topic_mapping')
        .get();
    for (var doc in snap.docs) {
      final data = doc.data();
      final topic = doc.id;
      final cefr = data['cefrLevel'] as String? ?? 'B1';
      _topicLevelCache[topic] = cefr;
    }
  }

  // ฟังก์ชันดึง CEFR Level สำหรับ topic แบบ Asynchronous
  static Future<String> getCEFRLevelForTopic(String topic) async {
    final doc = await FirebaseFirestore.instance
        .collection('quiz_topic_mapping')
        .doc(topic)
        .get();
    if (doc.exists) {
      final data = doc.data() ?? {};
      return data['cefrLevel'] as String? ?? 'B1';
    } else {
      return 'B1';
    }
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

  // ฟังก์ชันอัปเดตข้อมูลผู้ใช้เมื่อทำ Quiz สำเร็จ
  static Future<void> updateUserProgress(
      String userId,
      String topic,
      String rewardImageName,
      String cefrLevel,
      ) async {
    final db = FirebaseFirestore.instance;
    final userDoc = db.collection('users').doc(userId);
    final progressDoc = userDoc.collection('progress').doc('progress');

    // อัปเดต CEFR Level
    await progressDoc.set({
      'currentCEFRLevel': cefrLevel,
      'currentLevelBackground': '${cefrLevel}_background',
    }, SetOptions(merge: true));

    // เพิ่ม Document ใหม่ใน subcollection unlockedRewards
    if (rewardImageName.isNotEmpty) {
      await progressDoc.collection('unlockedRewards').add({
        'imageName': rewardImageName,
        'unlockedAt': FieldValue.serverTimestamp(),
        'topic': topic,
      });
    }
  }
}
