import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/app_logger.dart';
import '../model/flashcard_topic_model.dart';
import '../services/word_service.dart';

/// Repository for handling flashcard data operations
class FlashcardRepository {
  static const String _tag = 'FlashcardRepository';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final WordService _wordService = WordService();

  /// Fetch flashcards for a specific topic
  Future<List<Flashcard>> getFlashcardsForTopic(String topic) async {
    try {
      // Try to get flashcards from the new structure first
      return await _wordService.getWordsForCategory(topic);
    } catch (e) {
      AppLogger.i(
          _tag, 'Error fetching from word_categories, falling back: $e');
      // Fallback to legacy structure
      return await _getFlashcardsFromLegacyStructure(topic);
    }
  }

  /// Get flashcards from the legacy data structure
  Future<List<Flashcard>> _getFlashcardsFromLegacyStructure(
      String topic) async {
    String level = _wordService.getLevelFromCategory(topic);
    DocumentSnapshot levelSnapshot =
        await _firestore.collection('cefr_levels').doc(level).get();

    if (!levelSnapshot.exists || levelSnapshot.data() == null) {
      return [];
    }

    Map<String, dynamic> topics =
        (levelSnapshot.data() as Map<String, dynamic>)['topics'];

    if (!topics.containsKey(topic)) {
      return [];
    }

    List<dynamic> vocabularies = topics[topic]['vocabularies'] as List<dynamic>;

    return vocabularies.map((vocab) => Flashcard.fromMap(vocab)).toList();
  }

  /// Get user's known words for a specific topic
  Future<List<String>> getUserKnownWords(String userId, String topic) async {
    String level = _wordService.getLevelFromCategory(topic);

    QuerySnapshot userKnownVocabSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection(level)
        .doc(topic)
        .collection('vocabularies')
        .where('is_known', isEqualTo: true)
        .get();

    return userKnownVocabSnapshot.docs.map((doc) => doc.id).toList();
  }

  /// Save user's flashcard status
  Future<void> saveUserFlashcardStatus(
    String userId,
    String topic,
    Flashcard flashcard,
    bool isKnown,
    bool forReview,
  ) async {
    String level = _wordService.getLevelFromCategory(topic);
    final detail = await _wordService.getWordDetail(flashcard.id);

    if (detail == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection(level)
        .doc(topic)
        .collection('vocabularies')
        .doc(flashcard.mainWord)
        .set({
      'level': level,
      'topic': topic,
      'word': flashcard.mainWord,
      'is_known': isKnown,
      'for_review': forReview,
      'definition': detail.definition,
      'type': detail.partOfSpeech,
      'example_sentence': detail.examples.isNotEmpty ? detail.examples[0] : '',
      'hint': detail.hint,
    }, SetOptions(merge: true));
  }

  /// Count known words for a user and topic
  Future<int> countKnownWords(String userId, String topic) async {
    String level = _wordService.getLevelFromCategory(topic);

    QuerySnapshot query = await _firestore
        .collection('users')
        .doc(userId)
        .collection(level)
        .doc(topic)
        .collection('vocabularies')
        .where('is_known', isEqualTo: true)
        .where('for_review', isEqualTo: false)
        .get();

    return query.docs.length;
  }

  /// Count words marked for review
  Future<int> countReviewWords(String userId, String topic) async {
    String level = _wordService.getLevelFromCategory(topic);

    QuerySnapshot query = await _firestore
        .collection('users')
        .doc(userId)
        .collection(level)
        .doc(topic)
        .collection('vocabularies')
        .where('for_review', isEqualTo: true)
        .get();

    return query.docs.length;
  }

  /// Count unknown words
  Future<int> countUnknownWords(String userId, String topic) async {
    String level = _wordService.getLevelFromCategory(topic);

    QuerySnapshot query = await _firestore
        .collection('users')
        .doc(userId)
        .collection(level)
        .doc(topic)
        .collection('vocabularies')
        .where('is_known', isEqualTo: false)
        .where('for_review', isEqualTo: false)
        .get();

    return query.docs.length;
  }

  /// Get all categories for a CEFR level
  Future<List<Map<String, dynamic>>> getCategoriesForLevel(String level) async {
    try {
      // First try the new structure
      final snapshot = await _firestore
          .collection('word_categories')
          .where('cefrLevel', isEqualTo: level)
          .get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc.data()['name'] ?? doc.id.replaceAll('_', ' '),
          'wordCount': (doc.data()['words'] as List?)?.length ?? 0,
        };
      }).toList();
    } catch (e) {
      AppLogger.e(_tag, 'Error fetching from word_categories', e);
      // Fallback to old structure
      return await _getLegacyCategoriesForLevel(level);
    }
  }

  Future<List<Map<String, dynamic>>> _getLegacyCategoriesForLevel(
      String level) async {
    final levelDoc =
        await _firestore.collection('cefr_levels').doc(level).get();

    if (!levelDoc.exists || levelDoc.data() == null) {
      return [];
    }

    final topics = levelDoc.data()!['topics'] as Map<String, dynamic>;

    return topics.entries.map((entry) {
      return {
        'id': entry.key,
        'name': entry.key.replaceAll('_', ' '),
        'wordCount': (entry.value['vocabularies'] as List?)?.length ?? 0,
      };
    }).toList();
  }

  /// Reset all flashcard statuses for a specific topic
  Future<void> resetFlashcardsForTopic(String userId, String topic) async {
    String level = _wordService.getLevelFromCategory(topic);

    final query = await _firestore
        .collection('users')
        .doc(userId)
        .collection(level)
        .doc(topic)
        .collection('vocabularies')
        .get();

    final batch = _firestore.batch();

    for (var doc in query.docs) {
      batch.update(doc.reference, {
        'is_known': false,
        'for_review': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  /// Get unknown words for a user in a specific topic
  Future<List<Map<String, dynamic>>> getUnknownWords(
      String userId, String topic) async {
    String level = _wordService.getLevelFromCategory(topic);

    final query = await _firestore
        .collection('users')
        .doc(userId)
        .collection(level)
        .doc(topic)
        .collection('vocabularies')
        .where('is_known', isEqualTo: false)
        .where('for_review', isEqualTo: false)
        .get();

    return query.docs.map((doc) {
      final data = doc.data();
      return {
        'word': doc.id,
        ...data,
      };
    }).toList();
  }

  /// Update unknown words to be for review
  Future<void> addWordsToReview(
      String userId, String topic, List<String> words) async {
    String level = _wordService.getLevelFromCategory(topic);

    final batch = _firestore.batch();

    for (String word in words) {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection(level)
          .doc(topic)
          .collection('vocabularies')
          .doc(word);

      batch.update(docRef, {
        'for_review': true,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }
}
