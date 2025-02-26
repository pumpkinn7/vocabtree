import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/app_logger.dart';
import '../model/flashcard_topic_model.dart';
import '../model/swipe_direction.dart'; // Add this import

/// บริการจัดการข้อมูล flashcard ทั้งหมด
class FlashcardService {
  static const String _tag = 'FlashcardService';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ดึงคำศัพท์ของหมวดหมู่
  Future<List<Flashcard>> getFlashcardsForTopic(String topic) async {
    try {
      // ดึงข้อมูลหมวดหมู่
      final categoryDoc =
          await _firestore.collection('word_categories').doc(topic).get();
      if (!categoryDoc.exists || categoryDoc.data() == null) {
        AppLogger.i(_tag, 'ไม่พบหมวดหมู่ $topic');
        return [];
      }

      // ดึง cefrLevel จากหมวดหมู่
      final String cefrLevel = categoryDoc.data()?['cefrLevel'] ?? '';

      // ดึง ID คำศัพท์
      final List<String> wordIds =
          List<String>.from(categoryDoc.data()!['words'] ?? []);
      if (wordIds.isEmpty) {
        AppLogger.i(_tag, 'ไม่พบคำศัพท์ในหมวดหมู่ $topic');
        return [];
      }

      // ดึงข้อมูลคำศัพท์แต่ละคำ
      final List<Flashcard> flashcards = [];

      // แบ่งการดึงเป็นชุดละ 10 คำ เพื่อประสิทธิภาพ
      for (int i = 0; i < wordIds.length; i += 10) {
        final endIndex = (i + 10 < wordIds.length) ? i + 10 : wordIds.length;
        final batch = wordIds.sublist(i, endIndex);

        final wordsSnapshot = await _firestore
            .collection('words')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        for (var doc in wordsSnapshot.docs) {
          final data = doc.data();
          flashcards
              .add(Flashcard.fromWordDocument(doc.id, data, topic, cefrLevel));
        }
      }

      return flashcards;
    } catch (e) {
      AppLogger.e(_tag, 'ข้อผิดพลาดในการดึงคำศัพท์ $topic', e);
      return [];
    }
  }

  /// ดึงคำศัพท์ที่ผู้ใช้รู้แล้ว
  Future<List<String>> getUserKnownWords(String userId, String topic) async {
    String level = getLevelFromCategory(topic);

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

  /// บันทึกสถานะของ flashcard
  Future<void> saveUserFlashcardStatus(
    String userId,
    String topic,
    Flashcard flashcard,
    bool isKnown,
    bool forReview,
  ) async {
    String level = flashcard.cefrLevel;
    if (level.isEmpty) {
      level = getLevelFromCategory(topic);
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection(level)
        .doc(topic)
        .collection('vocabularies')
        .doc(flashcard.mainWord) // Changed from word to mainWord
        .set({
      'level': level,
      'topic': topic,
      'word': flashcard.mainWord, // Changed from word to mainWord
      'is_known': isKnown,
      'for_review': forReview,
      'definition':
          flashcard.definition, // เปลี่ยนจาก 'meaning' เป็น 'definition'
      'type': flashcard.partOfSpeech,
      // Remove exampleSentence as it's no longer available
      'cefrLevel': flashcard.cefrLevel,
    }, SetOptions(merge: true));
  }

  /// นับคำศัพท์ที่รู้แล้ว
  Future<int> countKnownWords(String userId, String topic) async {
    String level = getLevelFromCategory(topic);

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

  /// นับคำศัพท์ที่ต้องทบทวน
  Future<int> countReviewWords(String userId, String topic) async {
    String level = getLevelFromCategory(topic);

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

  /// นับคำศัพท์ที่ยังไม่รู้
  Future<int> countUnknownWords(String userId, String topic) async {
    String level = getLevelFromCategory(topic);

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

  /// ดึงข้อมูลของหมวดหมู่ในระดับ CEFR
  Future<List<Map<String, dynamic>>> getCategoriesForLevel(String level) async {
    try {
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
      AppLogger.e(_tag, 'เกิดข้อผิดพลาดในการดึงข้อมูลหมวดหมู่', e);
      return [];
    }
  }

  /// รีเซ็ตสถานะคำศัพท์ทั้งหมด
  Future<void> resetFlashcardsForTopic(String userId, String topic) async {
    String level = getLevelFromCategory(topic);

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
      });
    }

    await batch.commit();
  }

  /// ดึงคำศัพท์ที่ยังไม่รู้
  Future<List<Map<String, dynamic>>> getUnknownWords(
      String userId, String topic) async {
    String level = getLevelFromCategory(topic);

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
      return {'word': doc.id, ...data};
    }).toList();
  }

  /// เพิ่มคำศัพท์เข้าไปในรายการทบทวน
  Future<void> addWordsToReview(
      String userId, String topic, List<String> words) async {
    String level = getLevelFromCategory(topic);
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
      });
    }

    await batch.commit();
  }

  /// หา level จากชื่อหมวดหมู่
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
      return 'B1';
    }
  }

  /// ดึงข้อมูลระดับ CEFR จากหมวดหมู่
  Future<String> getCefrLevelFromCategory(String categoryId) async {
    try {
      final docSnap =
          await _firestore.collection('word_categories').doc(categoryId).get();
      if (docSnap.exists && docSnap.data() != null) {
        String cefrLevel =
            docSnap.data()!['cefrLevel'] ?? getLevelFromCategory(categoryId);

        return cefrLevel;
      }
    } catch (e) {
      AppLogger.e(_tag, 'ข้อผิดพลาดในการดึงข้อมูล CEFR', e);
    }
    return getLevelFromCategory(categoryId);
  }

  Future<Map<String, List<String>>> getWordStatuses(
    String userId,
    String topic,
  ) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('vocabulary_progress')
        .doc(topic)
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

  Future<void> saveWordStatus(
    String userId,
    String topic,
    String wordId,
    SwipeDirection direction,
  ) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('vocabulary_progress')
        .doc(topic);

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

  /// Reset all flashcard statuses for a specific topic
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

  Future<WordDetail?> getWordDetail(String wordId) async {
    try {
      final doc = await _firestore.collection('words').doc(wordId).get();
      if (!doc.exists) return null;
      return WordDetail.fromDocument(
          doc.id, doc.data()!, getLevelFromCategory(wordId));
    } catch (e) {
      return null;
    }
  }
}
