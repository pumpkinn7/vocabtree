// quiz_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizOption {
  final String option;
  final bool isCorrect;

  QuizOption({
    required this.option,
    required this.isCorrect,
  });

  factory QuizOption.fromMap(Map<String, dynamic> data) {
    return QuizOption(
      option: data['option'],
      isCorrect: data['isCorrect'],
    );
  }
}

class Quiz {
  final String id;
  final String question;
  final List<QuizOption> options;
  final DateTime createdAt;
  final DateTime updatedAt;

  Quiz({
    required this.id,
    required this.question,
    required this.options,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Quiz.fromDocument(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    var options = (data['options'] as List)
        .map((optionData) => QuizOption.fromMap(optionData))
        .toList();

    return Quiz(
      id: doc.id,
      question: data['question'],
      options: options,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}
