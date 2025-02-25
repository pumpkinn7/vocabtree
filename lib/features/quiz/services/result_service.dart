import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vocabtree/features/quiz/models/quiz_result.dart';

class ResultService {
  static Future<void> saveQuizResult(QuizResult result) async {
    try {
      final db = FirebaseFirestore.instance;

      final docRef = await db
          .collection('users')
          .doc(result.userId)
          .collection('quizHistory')
          .add(result.toJson());

      for (var word in result.wrongAnswers) {
        await db
            .collection('users')
            .doc(result.userId)
            .collection('wordStats')
            .doc(word)
            .set({
          'word': word,
          'wrongCount': FieldValue.increment(1),
          'lastWrongAt': FieldValue.serverTimestamp(),
          'quizHistory': FieldValue.arrayUnion([docRef.id]),
          'topic': result.topic,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      rethrow;
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
    String? topic,
  }) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('wordStats')
          .get();

      var docs = snapshot.docs;

      if (topic != null) {
        docs = docs.where((doc) => doc.data()['topic'] == topic).toList();
      }

      // เรียงตามจำนวนครั้งที่ตอบผิด (มากไปน้อย) และ lastWrongAt (ล่าสุดก่อน)
      docs.sort((a, b) {
        final aCount = a.data()['wrongCount'] as int? ?? 0;
        final bCount = b.data()['wrongCount'] as int? ?? 0;
        if (aCount != bCount) {
          return bCount.compareTo(aCount);
        }
        final aTime =
            (a.data()['lastWrongAt'] as Timestamp?)?.toDate() ?? DateTime(1900);
        final bTime =
            (b.data()['lastWrongAt'] as Timestamp?)?.toDate() ?? DateTime(1900);
        return bTime.compareTo(aTime);
      });

      // ตัดเอาเฉพาะจำนวนที่ต้องการ
      if (docs.length > limit) {
        docs = docs.sublist(0, limit);
      }

      return docs.map((doc) {
        final data = doc.data();
        return {
          'word': doc.id,
          'wrongCount': data['wrongCount'] as int? ?? 0,
          'lastWrongAt':
              (data['lastWrongAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          'topic': data['topic'] as String? ?? 'unknown',
        };
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
