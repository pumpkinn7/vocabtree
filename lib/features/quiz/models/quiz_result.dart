import 'package:cloud_firestore/cloud_firestore.dart';

class QuizResult {
  final String userId;
  final String topic;
  final int score;
  final int totalQuestions;
  final double percentage;
  final List<String> wrongAnswers;

  QuizResult({
    required this.userId,
    required this.topic,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.wrongAnswers,
  });

  Map<String, dynamic> toJson() => {
        'topic': topic,
        'score': score,
        'totalQuestions': totalQuestions,
        'percentage': percentage,
        'wrongAnswers': wrongAnswers,
        'doneAt': FieldValue.serverTimestamp(),
      };
}
