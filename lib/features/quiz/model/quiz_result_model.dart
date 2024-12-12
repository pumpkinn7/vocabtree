import 'package:cloud_firestore/cloud_firestore.dart';

class QuizResultModel {
  final String cefrLevel;
  final String topic;
  final int score;
  final int totalQuestions;
  final double percentage;
  final int timeTaken; // หน่วยเป็นวินาที หรือจะปรับใช้หน่วยอื่น ๆ ก็ได้
  final DateTime doneAt;

  QuizResultModel({
    required this.cefrLevel,
    required this.topic,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.timeTaken,
    required this.doneAt,
  });

  // ฟังก์ชันสร้าง object จาก map (ใช้ตอนดึงจาก Firestore)
  factory QuizResultModel.fromMap(Map<String, dynamic> data) {
    return QuizResultModel(
      cefrLevel: data['cefrLevel'] as String? ?? '',
      topic: data['topic'] as String? ?? '',
      score: (data['score'] as num?)?.toInt() ?? 0,
      totalQuestions: (data['totalQuestions'] as num?)?.toInt() ?? 0,
      percentage: (data['percentage'] as num?)?.toDouble() ?? 0.0,
      timeTaken: (data['timeTaken'] as num?)?.toInt() ?? 0,
      doneAt: (data['doneAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // ฟังก์ชันแปลง object เป็น map (ใช้ตอนบันทึกลง Firestore)
  Map<String, dynamic> toMap() {
    return {
      'cefrLevel': cefrLevel,
      'topic': topic,
      'score': score,
      'totalQuestions': totalQuestions,
      'percentage': percentage,
      'timeTaken': timeTaken,
      'doneAt': doneAt,
    };
  }
}
