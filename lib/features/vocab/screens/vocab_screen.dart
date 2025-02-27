import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/vocab_detail_dialog.dart';
import 'all_vocab_screen.dart';
import 'flashcard_for_review_screen.dart';

class VocabScreen extends StatefulWidget {
  const VocabScreen({super.key});

  @override
  VocabScreenState createState() => VocabScreenState();
}

class VocabScreenState extends State<VocabScreen> {
  static const Map<String, List<String>> levelMapping = {
    'B1': [
      'daily_life',
      'education',
      'entertainment',
      'environment_and_nature',
      'health_and_fitness',
      'travel_and_tourism',
    ],
    'B2': [
      'home_renovation_and_decor',
      'outdoor_activities_and_adventures',
      'music_and_performing_arts',
      'fitness_and_exercise',
      'cooking_and_culinary_skills',
      'pet_care_and_animal_welfare',
      'gardening_and_landscaping',
      'hobbies_and_crafts',
    ],
    'C1': [
      'urban_living',
      'digital_well_being',
      'cultural_festivals',
      'creative_writing',
      'nutrition_and_wellness',
      'interior_decorating',
      'fashion_trends',
      'event_planning',
    ],
    'C2': [
      'immersive_technologies',
      'cosmic_discoveries',
      'digital_finance',
      'adrenaline_activities',
      'smart_automation',
      'legends_and_lore',
      'criminal_investigation',
    ],
  };

  String? userId;
  Map<String, Map<String, List<String>>> reviewWords =
      {}; // level -> topic -> wordsList
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
    _fetchAllReviewWords();
  }

  Future<void> _fetchAllReviewWords() async {
    setState(() => isLoading = true);

    try {
      if (userId == null) return;

      for (var levelEntry in levelMapping.entries) {
        final level = levelEntry.key;
        final topics = levelEntry.value;
        reviewWords[level] = {};
        for (var topic in topics) {
          reviewWords[level]![topic] = [];
        }
      }

      for (var levelEntry in levelMapping.entries) {
        final level = levelEntry.key;
        final topics = levelEntry.value;

        for (var topic in topics) {
          final progressDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('vocabulary_progress')
              .doc(topic)
              .get();

          if (progressDoc.exists && progressDoc.data() != null) {
            final reviewWordsArr = progressDoc.data()!['review_words'] ?? [];

            if (reviewWordsArr.isNotEmpty) {
              setState(() {
                reviewWords[level]![topic] = List<String>.from(reviewWordsArr);
              });
            }
          }
        }
      }

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<Map<String, dynamic>?> _getVocabDataForWord(
      String level, String topic, String word) async {
    if (userId == null) return null;

    try {
      final docSnap = await FirebaseFirestore.instance
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

  Future<List<DocumentSnapshot>> _getVocabDocsFromReviewWords(
      String level, String topic) async {
    if (userId == null) return [];

    final reviewWordsList = reviewWords[level]?[topic] ?? [];
    if (reviewWordsList.isEmpty) return [];

    final List<DocumentSnapshot> vocabDocs = [];

    for (var word in reviewWordsList) {
      try {
        final docSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection(level)
            .doc(topic)
            .collection('vocabularies')
            .doc(word)
            .get();

        if (!docSnap.exists) {
          final wordDoc = await FirebaseFirestore.instance
              .collection('words')
              .doc(word)
              .get();

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

  Future<void> _removeFromReviewWords(
      String level, String topic, String word) async {
    if (userId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('vocabulary_progress')
          .doc(topic)
          .update({
        'review_words': FieldValue.arrayRemove([word])
      });

      setState(() {
        reviewWords[level]![topic]?.remove(word);
      });
    } catch (_) {
      // ไม่ต้องทำอะไรเมื่อเกิดข้อผิดพลาด
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vocab Screen')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchAllReviewWords,
              child: ListView(
                children: levelMapping.entries.map((levelEntry) {
                  final level = levelEntry.key;
                  final topics = levelEntry.value;

                  return ExpansionTile(
                    title: Text('ระดับ: $level'),
                    children: [
                      ...topics.map((topic) {
                        final wordsList = reviewWords[level]?[topic] ?? [];

                        if (wordsList.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'หัวข้อ: ${_formatTopicName(topic)}',
                                style: Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AllVocabScreen(level: level),
                                        ),
                                      );
                                    },
                                    child: const Text('ดูทั้งหมด'),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final vocabDocs =
                                          await _getVocabDocsFromReviewWords(
                                              level, topic);

                                      if (!mounted) return;

                                      if (vocabDocs.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'ไม่พบข้อมูลคำศัพท์')));
                                        return;
                                      }

                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              FlashcardForReviewScreen(
                                            level: level,
                                            topic: topic,
                                            userId: userId!,
                                            vocabDocs: vocabDocs,
                                          ),
                                        ),
                                      );
                                      _fetchAllReviewWords();
                                    },
                                    child: const Text('Flashcard'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Wrap(
                                spacing: 12.0,
                                runSpacing: 12.0,
                                alignment: WrapAlignment.center,
                                children: wordsList.map((word) {
                                  return OutlinedButton(
                                    onPressed: () async {
                                      final vocabData =
                                          await _getVocabDataForWord(
                                              level, topic, word);

                                      if (!mounted) return;

                                      if (vocabData == null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'ไม่พบข้อมูลสำหรับคำว่า "$word"')),
                                        );
                                        return;
                                      }

                                      showDialog(
                                        context: context,
                                        barrierDismissible: true,
                                        builder: (context) => VocabDetailDialog(
                                          wordId: word,
                                          vocabData: vocabData,
                                          level: level,
                                          topic: topic,
                                          userId: userId!,
                                          onRemoveWord: (word) =>
                                              _removeFromReviewWords(
                                                  level, topic, word),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 8.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      side: BorderSide(
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                    child:
                                        Text(word, textAlign: TextAlign.center),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }

  String _formatTopicName(String topic) {
    return topic
        .split('_')
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : '')
        .join(' ');
  }
}
