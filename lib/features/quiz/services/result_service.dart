import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart'; // Add this import
import 'package:vocabtree/features/quiz/models/quiz_result.dart';

class ResultService {
  static final _logger = Logger('ResultService');

  static Future<void> saveQuizResult(QuizResult result) async {
    final db = FirebaseFirestore.instance;

    // บันทึกลง quiz history
    final docRef = await db
        .collection('users')
        .doc(result.userId)
        .collection('quizHistory')
        .add(result.toJson());

    // บันทึกสถิติการตอบผิด
    for (var word in result.wrongAnswers) {
      await db
          .collection('users')
          .doc(result.userId)
          .collection('wordStats')
          .doc(word)
          .set({
        'wrongCount': FieldValue.increment(1),
        'lastWrongAt': FieldValue.serverTimestamp(),
        'quizHistory': FieldValue.arrayUnion([docRef.id]),
      }, SetOptions(merge: true));
    }
  }

  static Future<List<Map<String, dynamic>>> loadRecentQuizzes(
    String userId,
    String topic,
  ) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('quizHistory')
        .where('topic', isEqualTo: topic)
        .orderBy('doneAt', descending: true)
        .limit(4)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  static Future<List<Map<String, dynamic>>> getTopWrongWords(
    String userId, {
    int limit = 5,
  }) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('wordStats')
          .orderBy('wrongCount', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => {
                'word': doc.id,
                'wrongCount': doc.data()['wrongCount'] as int,
                'lastWrongAt':
                    (doc.data()['lastWrongAt'] as Timestamp).toDate(),
              })
          .toList();
    } catch (e) {
      _logger.warning('Error getting top wrong words', e);
      return [];
    }
  }
}
