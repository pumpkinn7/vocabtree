import 'package:cloud_firestore/cloud_firestore.dart';

class VocabService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ดึงข้อมูลคำศัพท์ทบทวนทั้งหมดสำหรับผู้ใช้
  Future<Map<String, Map<String, List<String>>>> fetchAllReviewWords(
      String userId, Map<String, List<String>> levelMapping) async {
    Map<String, Map<String, List<String>>> reviewWords = {};

    // สร้างโครงสร้างข้อมูลว่างเปล่า
    for (var levelEntry in levelMapping.entries) {
      final level = levelEntry.key;
      final topics = levelEntry.value;
      reviewWords[level] = {};
      for (var topic in topics) {
        reviewWords[level]![topic] = [];
      }
    }

    // ดึงข้อมูลจาก Firestore
    for (var levelEntry in levelMapping.entries) {
      final level = levelEntry.key;
      final topics = levelEntry.value;

      for (var topic in topics) {
        final progressDoc = await _firestore
            .collection('users')
            .doc(userId)
            .collection('vocabulary_progress')
            .doc(topic)
            .get();

        if (progressDoc.exists && progressDoc.data() != null) {
          final reviewWordsArr = progressDoc.data()!['review_words'] ?? [];

          if (reviewWordsArr.isNotEmpty) {
            reviewWords[level]![topic] = List<String>.from(reviewWordsArr);
          }
        }
      }
    }

    return reviewWords;
  }

  // ดึงข้อมูลคำศัพท์สำหรับคำเฉพาะ
  Future<Map<String, dynamic>?> getVocabDataForWord(
      String userId, String level, String topic, String word) async {
    try {
      final docSnap = await _firestore
          .collection('users')
          .doc(userId)
          .collection(level)
          .doc(topic)
          .collection('vocabularies')
          .doc(word)
          .get();

      if (docSnap.exists) {
        return docSnap.data();
      } else {
        return {'word': word, 'meaning': 'No definition available'};
      }
    } catch (_) {
      return {'word': word, 'meaning': 'Error loading data'};
    }
  }

  // ดึงข้อมูล DocumentSnapshot สำหรับคำศัพท์ทบทวน
  Future<List<DocumentSnapshot>> getVocabDocsFromReviewWords(String userId,
      String level, String topic, List<String> reviewWordsList) async {
    if (reviewWordsList.isEmpty) return [];

    final List<DocumentSnapshot> vocabDocs = [];

    for (var word in reviewWordsList) {
      try {
        final docSnap = await _firestore
            .collection('users')
            .doc(userId)
            .collection(level)
            .doc(topic)
            .collection('vocabularies')
            .doc(word)
            .get();

        if (!docSnap.exists) {
          final wordDoc = await _firestore.collection('words').doc(word).get();

          if (wordDoc.exists) {
            vocabDocs.add(wordDoc);
          }
        } else {
          vocabDocs.add(docSnap);
        }
      } catch (e) {
        // Silent error handling
      }
    }

    return vocabDocs;
  }

  // ลบคำศัพท์ออกจากรายการทบทวน
  Future<void> removeFromReviewWords(
      String userId, String topic, String word) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('vocabulary_progress')
        .doc(topic)
        .update({
      'review_words': FieldValue.arrayRemove([word])
    });
  }

  // แปลงชื่อหัวข้อให้อ่านง่าย
  static String formatTopicName(String topic) {
    return topic
        .split('_')
        .map(
            (w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }
}
