import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/flashcard_topic_model.dart';
import '../services/word_service.dart';

class FlashcardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final WordService _wordService = WordService();

  /// Fetch flashcards for a specific topic
  Future<List<Flashcard>> getFlashcardsForTopic(String topic) async {
    return await _wordService.getWordsForCategory(topic);
  }

  /// Get user's known words for a specific topic
  Future<List<String>> getUserKnownWords(String userId, String topic) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('vocabulary_progress')
        .doc(topic)
        .get();

    if (!doc.exists) return [];

    return List<String>.from(doc.data()?['known_words'] ?? []);
  }

  /// Reset all flashcard statuses for a specific topic
  Future<void> resetFlashcardsForTopic(String userId, String topic) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('vocabulary_progress')
        .doc(topic)
        .set({
      'known_words': [],
      'unknown_words': [],
      'review_words': [],
    });
  }

  /// Get unknown words for a user in a specific topic
  Future<List<Map<String, dynamic>>> getUnknownWords(
      String userId, String topic) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('vocabulary_progress')
        .doc(topic)
        .get();

    if (!doc.exists) return [];

    final unknownIds = List<String>.from(doc.data()?['unknown_words'] ?? []);
    List<Map<String, dynamic>> unknownWords = [];

    for (String id in unknownIds) {
      try {
        final wordDoc = await _firestore.collection('words').doc(id).get();
        if (wordDoc.exists) {
          unknownWords.add({'word': id, ...wordDoc.data()!});
        }
      } catch (e) {
        continue;
      }
    }

    return unknownWords;
  }
}
