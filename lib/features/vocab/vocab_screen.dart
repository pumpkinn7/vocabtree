import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';

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
  Map<String, Map<String, List<DocumentSnapshot>>> vocabData = {}; // level -> topic -> vocabDocs

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
    _fetchAllVocabularies();
  }

  Future<void> _fetchAllVocabularies() async {
    for (var levelEntry in levelMapping.entries) {
      final level = levelEntry.key;
      final topics = levelEntry.value;
      if (!vocabData.containsKey(level)) {
        vocabData[level] = {};
      }
      for (var topic in topics) {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection(level)
            .doc(topic)
            .collection('vocabularies')
            .where('for_review', isEqualTo: true)
            .get();

        setState(() {
          vocabData[level]![topic] = snapshot.docs;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vocab Screen')),
      body: ListView(
        children: levelMapping.entries.map((levelEntry) {
          final level = levelEntry.key;
          final topics = levelEntry.value;

          return ExpansionTile(
            title: Text('ระดับ: $level'),
            children: topics.map((topic) {
              final vocabDocs = vocabData[level]?[topic] ?? [];

              if (vocabDocs.isEmpty) {
                return const SizedBox.shrink(); // ไม่มีคำศัพท์ไม่แสดงหัวข้อ อย่าพึ่งลบ
              }

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'หัวข้อ: $topic',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 12.0,
                      runSpacing: 12.0,
                      alignment: WrapAlignment.center,
                      children: vocabDocs.map((doc) {
                        final vocabData = doc.data() as Map<String, dynamic>;
                        final word = vocabData['word'] ?? '';
                        final type = vocabData['type'] ?? '';
                        final meaning = vocabData['meaning'] ?? '';
                        final exampleSentence = vocabData['example_sentence'] ?? '';
                        final exampleTranslation = vocabData['example_translation'] ?? '';
                        final hint = vocabData['hint'] ?? '';
                        final hintTranslation = vocabData['hint_translation'] ?? '';
                        final FlutterTts flutterTts = FlutterTts();

                        return OutlinedButton(
                          onPressed: () {
                            _showVocabDialog(
                              context,
                              doc,
                              level,
                              topic,
                              word,
                              type,
                              meaning,
                              exampleSentence,
                              exampleTranslation,
                              hint,
                              hintTranslation,
                              flutterTts,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            side: BorderSide(color: Theme.of(context).primaryColor),
                          ),
                          child: Text(word, textAlign: TextAlign.center),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  void _showVocabDialog(
      BuildContext context,
      DocumentSnapshot doc,
      String level,
      String topic,
      String word,
      String type,
      String meaning,
      String exampleSentence,
      String exampleTranslation,
      String hint,
      String hintTranslation,
      FlutterTts flutterTts,
      ) {
    bool isShowingTranslation = false; // ตัวแปรสถานะแสดงการแปล

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$word - คำ$type', style: Theme.of(context).textTheme.titleLarge),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.volume_up, color: Colors.blue),
                      onPressed: () async {
                        await flutterTts.speak(word);
                      },
                    ),
                    const SizedBox(height: 10),
                    Text('หมวดหมู่ : $topic', style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 10),
                    Text('ความหมาย : $meaning', style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 10),
                    Text(
                      'ตัวอย่าง : ${isShowingTranslation ? exampleTranslation : exampleSentence}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'คำใบ้ : ${isShowingTranslation ? hintTranslation : hint}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('แปลภาษา'),
                  onPressed: () {
                    setStateDialog(() {
                      isShowingTranslation = !isShowingTranslation;
                    });
                  },
                ),
                TextButton(
                  child: const Text('ลบออกจากคลัง', style: TextStyle(color: Colors.orange)),
                  onPressed: () async {
                    // อัปเดต Firebase
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .collection(level)
                        .doc(topic)
                        .collection('vocabularies')
                        .doc(doc.id)
                        .update({'for_review': false});

                    // ลบคำศัพท์
                    setState(() {
                      vocabData[level]![topic]!.remove(doc);
                    });

                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
