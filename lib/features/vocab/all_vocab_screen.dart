import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AllVocabScreen extends StatefulWidget {
  final String level;

  const AllVocabScreen({super.key, required this.level});

  @override
  AllVocabScreenState createState() => AllVocabScreenState();
}

class AllVocabScreenState extends State<AllVocabScreen> {
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

  Map<String, List<Map<String, dynamic>>> topicVocabMap = {};
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
    _fetchAllVocabularies();
  }

  Future<void> _fetchAllVocabularies() async {
    Map<String, List<Map<String, dynamic>>> vocabMap = {};
    try {
      DocumentSnapshot levelSnapshot = await FirebaseFirestore.instance
          .collection('cefr_levels')
          .doc(widget.level)
          .get();

      if (levelSnapshot.exists) {
        Map<String, dynamic> levelData =
        levelSnapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> topics = levelData['topics'] ?? {};

        for (var topic in levelMapping[widget.level] ?? []) {
          if (topics.containsKey(topic)) {
            Map<String, dynamic> topicData = topics[topic];
            List<dynamic> vocabularies = topicData['vocabularies'] ?? [];

            for (var vocabData in vocabularies) {
              if (vocabData is Map<String, dynamic>) {
                if (!vocabMap.containsKey(topic)) {
                  vocabMap[topic] = [];
                }
                vocabMap[topic]?.add({
                  'topic': topic,
                  ...vocabData,
                });
              }
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching vocabularies: $e');
      }
    }

    setState(() {
      topicVocabMap = vocabMap;
    });
  }

  void _showVocabDialog(Map<String, dynamic> vocabData) {
    bool isShowingTranslation = false;
    final FlutterTts flutterTts = FlutterTts();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${vocabData['word']} - คำ${vocabData['type']}'),
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
                        await flutterTts.speak(vocabData['word']);
                      },
                    ),
                    const SizedBox(height: 10),
                    Text('หัวข้อ: ${vocabData['topic']}'),
                    const SizedBox(height: 10),
                    Text('ความหมาย: ${vocabData['meaning']}'),
                    const SizedBox(height: 10),
                    Text(
                      'ตัวอย่าง: ${isShowingTranslation ? vocabData['example_translation'] : vocabData['example_sentence']}',
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'คำใบ้: ${isShowingTranslation ? vocabData['hint_translation'] : vocabData['hint']}',
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
                  child: const Text('เพิ่มเข้าคลังคำศัพท์'),
                  onPressed: () async {
                    await _addToVocabularyBank(vocabData);
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

  Future<void> _addToVocabularyBank(Map<String, dynamic> vocabData) async {
    if (userId == null) {
      if (kDebugMode) {
        print('ยังไม่ login');
      }
      return;
    }

    String level = widget.level;
    String topic = vocabData['topic'];

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection(level)
        .doc(topic)
        .collection('vocabularies')
        .doc(vocabData['word'])
        .set({
      'userId': userId,
      'level': level,
      'topic': topic,
      'word': vocabData['word'],
      'meaning': vocabData['meaning'],
      'type': vocabData['type'],
      'example_sentence': vocabData['example_sentence'] ?? '',
      'example_translation': vocabData['example_translation'] ?? '',
      'hint': vocabData['hint'] ?? '',
      'hint_translation': vocabData['hint_translation'] ?? '',
      'for_review': true,
      'is_known': false,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('คำศัพท์ทั้งหมด ระดับ ${widget.level}'),
      ),
      body: topicVocabMap.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: topicVocabMap.entries.map((entry) {
          String topic = entry.key;
          List<Map<String, dynamic>> vocabList = entry.value;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // หัวข้อ
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    topic.replaceAll('_', ' ').toUpperCase(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 8.0),
                // คำศัพท์เป็นปุ่ม
                Wrap(
                  spacing: 12.0,
                  runSpacing: 12.0,
                  alignment: WrapAlignment.start,
                  children: vocabList.map((vocabData) {
                    final word = vocabData['word'] ?? '';

                    return OutlinedButton(
                      onPressed: () {
                        _showVocabDialog(vocabData);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        side: BorderSide(
                            color: Theme.of(context).primaryColor),
                      ),
                      child: Text(word, textAlign: TextAlign.center),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
