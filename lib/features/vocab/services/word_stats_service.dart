import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vocabtree/utils/app_logger.dart';

class WordStatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _tag = 'WordStatsService';

  Future<List<Map<String, dynamic>>> getMostReviewedWords(String userId) async {
    try {
      // แทนที่จะนับจำนวนครั้งที่คำปรากฏ เราจะนับจำนวน topics ที่มีคำนั้น
      final allWords = <String>{};
      final wordTopicCount = <String, int>{};

      // 1. ดึงข้อมูลจาก vocabulary_progress collection
      final progressSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('vocabulary_progress')
          .get();

      if (progressSnapshot.docs.isEmpty) {
        return [];
      }

      AppLogger.i(
          _tag, 'Found ${progressSnapshot.docs.length} progress documents');

      // 2. รวบรวมคำทั้งหมดก่อน และนับ topic ที่มีคำนั้น
      for (var doc in progressSnapshot.docs) {
        final data = doc.data();
        final topicId = doc.id;

        AppLogger.i(_tag, 'Processing topic: $topicId');

        if (data.containsKey('review_words')) {
          final reviewWords = data['review_words'];

          if (reviewWords is List) {
            // ใช้ whereType แทน where().cast<>()
            final uniqueWords =
                Set<String>.from(reviewWords.whereType<String>());

            // เพิ่มคำทั้งหมดเข้าเซ็ต
            allWords.addAll(uniqueWords);

            // สำหรับแต่ละคำในหัวข้อนี้ เพิ่มจำนวน topic ที่มีคำนี้
            for (final word in uniqueWords) {
              wordTopicCount[word] = (wordTopicCount[word] ?? 0) + 1;
            }
          }
        }
      }

      AppLogger.i(_tag, 'Total unique words found: ${allWords.length}');
      AppLogger.i(_tag, 'Word topic counts: $wordTopicCount');

      // 3. เรียงลำดับตามจำนวน topics ที่คำนั้นปรากฏ
      final sortedWords = wordTopicCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      if (sortedWords.isEmpty) {
        return [];
      }

      // พิมพ์ข้อมูล 3 อันดับแรกเพื่อดูค่า
      for (int i = 0; i < sortedWords.length && i < 3; i++) {
        AppLogger.i(_tag,
            'Top ${i + 1}: ${sortedWords[i].key} - appears in ${sortedWords[i].value} topics');
      }

      // ให้นับคำที่ปรากฏใน topics มากกว่า 1 topic ขึ้นไปก่อน
      final multiTopicWords =
          sortedWords.where((entry) => entry.value > 1).toList();
      final singleTopicWords =
          sortedWords.where((entry) => entry.value == 1).toList();

      // รวมรายการและเลือก 3 อันดับแรก
      final topWords = [...multiTopicWords, ...singleTopicWords].take(3);
      final results = <Map<String, dynamic>>[];

      // 4. ดึงข้อมูลเพิ่มเติมจาก words collection
      for (var entry in topWords) {
        final wordDoc =
            await _firestore.collection('words').doc(entry.key).get();

        if (!wordDoc.exists) {
          AppLogger.i(_tag, 'Word document not found: ${entry.key}');
          continue;
        }

        final data = wordDoc.data()!;
        String type = '';
        String cefrLevel = '';
        String definition = '';

        if (data['senses'] is List && (data['senses'] as List).isNotEmpty) {
          final firstSense = (data['senses'] as List)[0];
          type = firstSense['partOfSpeech'] ?? data['mainPos'] ?? '';
          cefrLevel = firstSense['cefr'] ?? data['cefrLevel'] ?? '';
          definition = firstSense['definition'] ?? '';
        } else {
          type = data['mainPos'] ?? data['type'] ?? '';
          cefrLevel = data['cefrLevel'] ?? '';
          definition = data['definition'] ?? '';
        }

        results.add({
          'word': entry.key,
          'count': entry.value,
          'type': type,
          'cefrLevel': cefrLevel,
          'definition': definition,
        });
      }

      return results;
    } catch (e) {
      AppLogger.e(_tag, 'Error getting most reviewed words', e);
      return [];
    }
  }

  // เมธอดสำหรับดึงคำที่ผู้ใช้ทุกคนบันทึกบ่อยที่สุด
  Future<List<Map<String, dynamic>>> getTopSavedWordsByAllUsers(
      int limit) async {
    try {
      Map<String, int> wordCount = {};
      Map<String, Map<String, dynamic>> wordDetails = {};

      // ดึงรายการผู้ใช้ทั้งหมด
      final usersSnapshot = await _firestore.collection('users').get();

      // รวบรวมคำทั้งหมดจากทุกผู้ใช้และทุกหัวข้อ
      for (var userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;

        // ดึง vocabulary_progress ของผู้ใช้คนนี้
        final progressSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('vocabulary_progress')
            .get();

        // วนลูปผ่านแต่ละ topic ใน vocabulary_progress
        for (var progressDoc in progressSnapshot.docs) {
          if (!progressDoc.exists) continue;

          final data = progressDoc.data();

          // ดึงรายการ review_words จากทุกหัวข้อ
          if (data.containsKey('review_words')) {
            final reviewWords = List<String>.from(data['review_words'] ?? []);

            // นับจำนวนการบันทึกของแต่ละคำ
            for (var word in reviewWords) {
              wordCount[word] = (wordCount[word] ?? 0) + 1;

              // ดึงข้อมูลเพิ่มเติมของคำศัพท์ถ้ายังไม่มี
              if (!wordDetails.containsKey(word)) {
                try {
                  final wordDoc =
                      await _firestore.collection('words').doc(word).get();
                  if (wordDoc.exists && wordDoc.data() != null) {
                    final wordData = wordDoc.data()!;
                    String type = '';

                    // หา part of speech จากข้อมูล
                    if (wordData.containsKey('mainPos')) {
                      type = wordData['mainPos'];
                    } else if (wordData.containsKey('senses') &&
                        wordData['senses'] is List &&
                        (wordData['senses'] as List).isNotEmpty) {
                      final firstSense = (wordData['senses'] as List)[0];
                      if (firstSense is Map) {
                        type = firstSense['partOfSpeech'] ?? '';
                      }
                    }

                    wordDetails[word] = {
                      'type': type,
                    };
                  }
                } catch (e) {
                  wordDetails[word] = {'type': ''};
                }
              }
            }
          }
        }
      }

      // เรียงลำดับคำตามจำนวนที่บันทึกมากไปน้อย
      final sortedWords = wordCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // จำกัดจำนวนตาม limit
      final limitedWords = sortedWords.take(limit).toList();

      // แปลงเป็นรูปแบบที่ต้องการส่งกลับ
      return limitedWords.map((entry) {
        final details = wordDetails[entry.key] ?? {'type': ''};
        return {
          'word': entry.key,
          'type': details['type'] ?? '',
          'saveCount': entry.value,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
