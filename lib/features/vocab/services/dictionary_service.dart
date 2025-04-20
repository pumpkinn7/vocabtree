import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DictionaryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, List<String>>> fetchWordsByLevel(String level) async {
    final Map<String, List<String>> topicWords = {};

    try {
      final categoriesQuery = await _firestore
          .collection('word_categories')
          .where('cefrLevel', isEqualTo: level)
          .get();

      for (var doc in categoriesQuery.docs) {
        final words = List<String>.from(doc.data()['words'] ?? []);
        topicWords[doc.id] = words;
      }

      return topicWords;
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, dynamic>?> fetchWordDetail(String wordId) async {
    try {
      final wordDoc = await _firestore.collection('words').doc(wordId).get();
      if (!wordDoc.exists) return null;
      
      final data = wordDoc.data();
      if (data == null) return null;
      
      if (!data.containsKey('partOfSpeech')) {
        if (data.containsKey('mainPos') && data['mainPos'] != null) {
          data['partOfSpeech'] = data['mainPos'];
        } 
        // ตรวจสอบจาก senses array ซึ่งมักจะมี partOfSpeech อยู่ในนั้น
        else if (data.containsKey('senses') && data['senses'] is List && data['senses'].isNotEmpty) {
          final firstSense = data['senses'][0];
          if (firstSense is Map && firstSense.containsKey('partOfSpeech') && firstSense['partOfSpeech'] != null) {
            data['partOfSpeech'] = firstSense['partOfSpeech'];
          } else {
            for (var sense in data['senses']) {
              if (sense is Map && sense.containsKey('partOfSpeech') && sense['partOfSpeech'] != null) {
                data['partOfSpeech'] = sense['partOfSpeech'];
                break;
              }
            }
            
            if (!data.containsKey('partOfSpeech')) {
              data['partOfSpeech'] = 'unknown';
            }
          }
        } else {
          data['partOfSpeech'] = 'unknown';
        }
      }
      
      return data;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching word detail: $e');
      }
      return null;
    }
  }

  String formatTopicName(String topic) {
    return topic
        .split('_')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  Map<String, List<String>> getSortedWords(List<String> words) {
    final Map<String, List<String>> sortedMap = {};
    final sortedWords = List<String>.from(words)..sort();
    for (var word in sortedWords) {
      if (word.isEmpty) continue;
      final firstLetter = word[0].toUpperCase();
      if (!sortedMap.containsKey(firstLetter)) {
        sortedMap[firstLetter] = [];
      }
      sortedMap[firstLetter]!.add(word);
    }
    return sortedMap;
  }
}
