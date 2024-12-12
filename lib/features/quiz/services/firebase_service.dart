import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/quiz_question_model.dart';

class FirebaseService {
  // สมมติว่ามีการเก็บ mapping ระหว่าง topic กับ cefrLevel ใน collection 'quiz_topic_mapping'
  // เอกสารเช่น: quiz_topic_mapping/{topicName} => { 'cefrLevel': 'B1' }
  static Future<String> getCEFRLevelForTopic(String topic) async {
    final doc = await FirebaseFirestore.instance
        .collection('quiz_topic_mapping')
        .doc(topic)
        .get();
    if (doc.exists) {
      final data = doc.data() ?? {};
      return data['cefrLevel'] as String? ?? 'B1';
      // ถ้าหาไม่เจอให้ default เป็น B1 หรือปรับตามต้องการ
    } else {
      // ถ้าไม่มี mapping ก็ default เป็น B1 หรือหาวิธีอื่น
      return 'B1';
    }
  }

  // สำหรับการเรียกแบบ synchronous ถ้าจำเป็น (ควรหลีกเลี่ยง)
  // สมมุติใช้ตัวแปร static เก็บ Mapping
  // ในกรณีที่จำเป็นต้องมีฟังก์ชัน sync อาจใช้ FutureBuilder หรือรอข้อมูลให้พร้อมก่อน
  static final Map<String, String> _topicLevelCache = {};
  static Future<void> preloadTopicLevels() async {
    // ดึงข้อมูลทั้งหมดจาก quiz_topic_mapping มาเก็บใน cache
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

  static String getCEFRLevelForTopicSync(String topic) {
    return _topicLevelCache[topic] ?? 'B1';
  }

  static Future<List<QuizQuestionModel>> getQuestionsForTopic(String cefrLevel, String topic) async {
    List<QuizQuestionModel> questions = [];
    // ประเภทคำถาม
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
      // drag_and_drop มี field: question, draggableItems, targets, correctMatches
        return QuizQuestionModel(
          type: QuestionType.dragAndDrop,
          question: data['question'] as String? ?? '',
          draggableItems: (data['draggableItems'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
          targets: (data['targets'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
          correctMatches: (data['correctMatches'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v.toString())) ?? {},
        );
      case 'matching':
      // matching มี field: question, leftItems, rightItems, correctMatches
        return QuizQuestionModel(
          type: QuestionType.matching,
          question: data['question'] as String? ?? '',
          leftItems: (data['leftItems'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
          rightItems: (data['rightItems'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
          correctMatches: (data['correctMatches'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v.toString())) ?? {},
        );
      default:
        return null;
    }
  }
}
