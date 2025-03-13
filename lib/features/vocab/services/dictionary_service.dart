import 'package:cloud_firestore/cloud_firestore.dart';

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
      return wordDoc.data();
    } catch (e) {
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
