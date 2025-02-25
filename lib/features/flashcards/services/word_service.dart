import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/app_logger.dart';
import '../model/flashcard_topic_model.dart';
import '../model/swipe_direction.dart';

class WordService {
  static const String _tag = 'WordService';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all categories for a specific CEFR level
  Future<List<String>> getCategoriesByLevel(String level) async {
    final snapshot = await _firestore
        .collection('word_categories')
        .where('cefrLevel', isEqualTo: level)
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  // Fetch words for a specific category
  Future<List<Flashcard>> getWordsForCategory(String categoryId) async {
    try {
      // Get the category document to fetch word list
      final categoryDoc =
          await _firestore.collection('word_categories').doc(categoryId).get();

      if (!categoryDoc.exists || categoryDoc.data() == null) {
        return [];
      }

      // Get CEFR level from category
      String cefrLevel =
          categoryDoc.data()?['cefrLevel'] ?? getLevelFromCategory(categoryId);

      // Get words array from the category
      final List<String> wordIds =
          List<String>.from(categoryDoc.data()!['words'] ?? []);

      if (wordIds.isEmpty) {
        return [];
      }

      // Fetch each word document
      final List<Flashcard> flashcards = [];

      // Use batching for efficiency - fetch words in batches of 10
      for (int i = 0; i < wordIds.length; i += 10) {
        final endIndex = (i + 10 < wordIds.length) ? i + 10 : wordIds.length;
        final batch = wordIds.sublist(i, endIndex);

        final wordsSnapshot = await _firestore
            .collection('words')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        for (var doc in wordsSnapshot.docs) {
          final data = doc.data();

          // Convert each word document to a Flashcard object - add cefrLevel parameter
          flashcards.add(
              Flashcard.fromWordDocument(doc.id, data, categoryId, cefrLevel));
        }
      }

      return flashcards;
    } catch (e) {
      AppLogger.e(_tag, 'Error getting words for category $categoryId', e);
      return [];
    }
  }

  // Save user's progress with a flashcard
  Future<void> saveUserFlashcardStatus(
      String userId,
      String level,
      String categoryId,
      Flashcard flashcard,
      bool isKnown,
      bool forReview) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection(level)
        .doc(categoryId)
        .collection('vocabularies')
        .doc(flashcard.word)
        .set({
      'level': level,
      'topic': categoryId,
      'word': flashcard.word,
      'is_known': isKnown,
      'for_review': forReview,
      'definition':
          flashcard.definition, // เปลี่ยนจาก 'meaning' เป็น 'definition'
      'type': flashcard.partOfSpeech,
      'example_sentence': flashcard.exampleSentence['sentence'] ?? '',
      'cefrLevel': flashcard.cefrLevel,
    }, SetOptions(merge: true));
  }

  // Get the CEFR level based on category ID
  String getLevelFromCategory(String categoryId) {
    if (categoryId.startsWith('daily_life') ||
        categoryId.startsWith('education') ||
        categoryId.startsWith('entertainment') ||
        categoryId.startsWith('environment_and_nature') ||
        categoryId.startsWith('health_and_fitness') ||
        categoryId.startsWith('travel_and_tourism') ||
        categoryId.startsWith('work_and_business')) {
      return 'B1';
    } else if (categoryId.startsWith('home_renovation_and_decor') ||
        categoryId.startsWith('outdoor_activities_and_adventures') ||
        categoryId.startsWith('music_and_performing_arts') ||
        categoryId.startsWith('fitness_and_exercise') ||
        categoryId.startsWith('cooking_and_culinary_skills') ||
        categoryId.startsWith('pet_care_and_animal_welfare') ||
        categoryId.startsWith('gardening_and_landscaping') ||
        categoryId.startsWith('hobbies_and_crafts')) {
      return 'B2';
    } else if (categoryId.startsWith('urban_living') ||
        categoryId.startsWith('digital_well_being') ||
        categoryId.startsWith('cultural_festivals') ||
        categoryId.startsWith('creative_writing') ||
        categoryId.startsWith('nutrition_and_wellness') ||
        categoryId.startsWith('interior_decorating') ||
        categoryId.startsWith('fashion_trends') ||
        categoryId.startsWith('event_planning')) {
      return 'C1';
    } else if (categoryId.startsWith('immersive_technologies') ||
        categoryId.startsWith('cosmic_discoveries') ||
        categoryId.startsWith('digital_finance') ||
        categoryId.startsWith('adrenaline_activities') ||
        categoryId.startsWith('smart_automation') ||
        categoryId.startsWith('legends_and_lore') ||
        categoryId.startsWith('criminal_investigation')) {
      return 'C2';
    } else {
      // Default level
      return 'B1';
    }
  }

  Future<void> saveWordStatus(
    String userId,
    String topicId,
    String wordId,
    SwipeDirection direction,
  ) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('vocabulary_progress')
        .doc(topicId);

    String field = 'unknown_words'; // Default value
    switch (direction) {
      case SwipeDirection.right:
        field = 'known_words';
        break;
      case SwipeDirection.left:
        field = 'unknown_words';
        break;
      case SwipeDirection.up:
        field = 'review_words';
        break;
    }

    await docRef.set({
      field: FieldValue.arrayUnion([wordId]),
      // 'last_updated' field removed as requested
    }, SetOptions(merge: true));
  }

  Future<Map<String, List<String>>> getWordStatuses(
    String userId,
    String topicId,
  ) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('vocabulary_progress')
        .doc(topicId)
        .get();

    if (!doc.exists) {
      return {
        'known_words': [],
        'unknown_words': [],
        'review_words': [],
      };
    }

    return {
      'known_words': List<String>.from(doc.data()?['known_words'] ?? []),
      'unknown_words': List<String>.from(doc.data()?['unknown_words'] ?? []),
      'review_words': List<String>.from(doc.data()?['review_words'] ?? []),
    };
  }

  Future<void> resetTopic(String userId, String topicId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('vocabulary_progress')
        .doc(topicId)
        .set({
      'known_words': [],
      'unknown_words': [],
      'review_words': [],
      // 'last_updated' field removed as requested
    });
  }
}
