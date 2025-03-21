import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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

      // กรองเฉพาะคำที่อยู่ใน topic ที่ระบุ
      if (topic != null) {
        docs = docs.where((doc) => doc.data()['topic'] == topic).toList();
      }

      // แปลง DocumentSnapshot เป็น Map และจัดการข้อมูล
      final List<Map<String, dynamic>> wordStats = docs.map((doc) {
        final data = doc.data();
        return {
          'word': data['word'] ?? '',
          'wrongCount': data['wrongCount'] ?? 0,
          'topic': data['topic'] ?? '',
          'lastWrongAt': data['lastWrongAt']?.toDate() ?? DateTime.now(),
        };
      }).toList();

      // เรียงตามจำนวนครั้งที่ตอบผิดมากไปน้อย
      wordStats.sort(
          (a, b) => (b['wrongCount'] as int).compareTo(a['wrongCount'] as int));

      // จำกัดจำนวนผลลัพธ์
      return wordStats.take(limit).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting wrong words: $e');
      }
      return [];
    }
  }
}
