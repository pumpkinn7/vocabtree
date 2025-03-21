import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vocabtree/utils/app_logger.dart';

class WordStatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _tag = 'WordStatsService';

  Future<List<Map<String, dynamic>>> getMostReviewedWords(String userId) async {
    try {
      final allWords = <String>{};
      final wordTopicCount = <String, int>{};

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

      for (var doc in progressSnapshot.docs) {
        final data = doc.data();
        final topicId = doc.id;

        AppLogger.i(_tag, 'Processing topic: $topicId');

        if (data.containsKey('review_words')) {
          final reviewWords = data['review_words'];

          if (reviewWords is List) {
            final uniqueWords =
                Set<String>.from(reviewWords.whereType<String>());

            allWords.addAll(uniqueWords);

            for (final word in uniqueWords) {
              wordTopicCount[word] = (wordTopicCount[word] ?? 0) + 1;
            }
          }
        }
      }

      AppLogger.i(_tag, 'Total unique words found: ${allWords.length}');
      AppLogger.i(_tag, 'Word topic counts: $wordTopicCount');

      final sortedWords = wordTopicCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      if (sortedWords.isEmpty) {
        return [];
      }

      for (int i = 0; i < sortedWords.length && i < 3; i++) {
        AppLogger.i(_tag,
            'Top ${i + 1}: ${sortedWords[i].key} - appears in ${sortedWords[i].value} topics');
      }

      final multiTopicWords =
          sortedWords.where((entry) => entry.value > 1).toList();
      final singleTopicWords =
          sortedWords.where((entry) => entry.value == 1).toList();

      final topWords = [...multiTopicWords, ...singleTopicWords].take(3);
      final results = <Map<String, dynamic>>[];

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

  Future<List<Map<String, dynamic>>> getTopSavedWordsByAllUsers(
      int limit) async {
    try {
      Map<String, int> wordCount = {};
      Map<String, Map<String, dynamic>> wordDetails = {};

      final usersSnapshot = await _firestore.collection('users').get();

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

            for (var word in reviewWords) {
              wordCount[word] = (wordCount[word] ?? 0) + 1;

              if (!wordDetails.containsKey(word)) {
                try {
                  final wordDoc =
                      await _firestore.collection('words').doc(word).get();
                  if (wordDoc.exists && wordDoc.data() != null) {
                    final wordData = wordDoc.data()!;
                    String type = '';

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

      final sortedWords = wordCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final limitedWords = sortedWords.take(limit).toList();

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
