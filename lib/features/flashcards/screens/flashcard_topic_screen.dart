import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:vocabtree/features/flashcards/model/flashcard_topic_model.dart';

class FlashcardScreen extends StatefulWidget {
  final String topic;

  const FlashcardScreen({super.key, required this.topic});

  @override
  FlashcardScreenState createState() => FlashcardScreenState();
}

class FlashcardScreenState extends State<FlashcardScreen> {
  late List<SwipeItem> _swipeItems;
  late MatchEngine _matchEngine;
  int knownCount = 0;
  int unknownCount = 0;
  final FlutterTts flutterTts = FlutterTts();
  bool isShowingMeaning = false;
  int currentIndex = 0; // เพิ่มตัวแปรนี้เพื่อติดตามคำศัพท์ปัจจุบัน

  @override
  void initState() {
    super.initState();
    _swipeItems = [];
    _matchEngine = MatchEngine(swipeItems: _swipeItems);
    _fetchFlashcards();
  }

  Future<void> _fetchFlashcards() async {
    try {
      String level = '';
      if (widget.topic.startsWith('daily_life') ||
          widget.topic.startsWith('education') ||
          widget.topic.startsWith('entertainment') ||
          widget.topic.startsWith('environment_and_nature') ||
          widget.topic.startsWith('health_and_fitness') ||
          widget.topic.startsWith('travel_and_tourism')) {
        level = 'B1';
      } else if (widget.topic.startsWith('home_renovation_and_decor') ||
          widget.topic.startsWith('outdoor_activities_and_adventures') ||
          widget.topic.startsWith('music_and_performing_arts') ||
          widget.topic.startsWith('fitness_and_exercise') ||
          widget.topic.startsWith('cooking_and_culinary_skills') ||
          widget.topic.startsWith('pet_care_and_animal_welfare') ||
          widget.topic.startsWith('gardening_and_landscaping') ||
          widget.topic.startsWith('hobbies_and_crafts')) {
        level = 'B2';
      } else if (widget.topic.startsWith('urban_living') ||
          widget.topic.startsWith('digital_well_being') ||
          widget.topic.startsWith('cultural_festivals') ||
          widget.topic.startsWith('creative_writing') ||
          widget.topic.startsWith('nutrition_and_wellness') ||
          widget.topic.startsWith('interior_decorating') ||
          widget.topic.startsWith('fashion_trends') ||
          widget.topic.startsWith('event_planning')) {
        level = 'C1';
      } else if (widget.topic.startsWith('immersive_technologies') ||
          widget.topic.startsWith('cosmic_discoveries') ||
          widget.topic.startsWith('digital_finance') ||
          widget.topic.startsWith('adrenaline_activities') ||
          widget.topic.startsWith('smart_automation') ||
          widget.topic.startsWith('legends_and_lore') ||
          widget.topic.startsWith('criminal_investigation')) {
        level = 'C2';
      }

      DocumentSnapshot levelSnapshot = await FirebaseFirestore.instance
          .collection('cefr_levels')
          .doc(level)
          .get();

      if (levelSnapshot.exists) {
        Map<String, dynamic>? topics = (levelSnapshot.data() as Map<String, dynamic>)['topics'];


        if (topics != null && topics.containsKey(widget.topic)) {
          List<dynamic>? vocabularies = (topics[widget.topic] as Map<String, dynamic>)['vocabularies'];

          if (vocabularies != null) {
            vocabularies.shuffle();

            setState(() {
              _swipeItems = vocabularies.map((vocab) {
                return Flashcard.fromMap(vocab);
              }).map((flashcard) {
                return SwipeItem(
                  content: flashcard,
                  likeAction: () {
                    setState(() {
                      knownCount++;
                      currentIndex++; // อัปเดตคำศัพท์ปัจจุบัน
                      isShowingMeaning = false; // รีเซ็ตสถานะ
                    });
                    if (kDebugMode) {
                      print("Liked ${flashcard.word}");
                    }
                  },
                  nopeAction: () {
                    setState(() {
                      unknownCount++;
                      currentIndex++; // อัปเดตคำศัพท์ปัจจุบัน
                      isShowingMeaning = false; // รีเซ็ตสถานะ
                    });
                    if (kDebugMode) {
                      print("Nope ${flashcard.word}");
                    }
                  },
                );
              }).toList();
              _matchEngine = MatchEngine(swipeItems: _swipeItems);
            });
          } else {
            if (kDebugMode) {
              print("No vocabularies found for topic: ${widget.topic}");
            }
          }
        } else {
          if (kDebugMode) {
            print("Topic does not exist in level: ${widget.topic}");
          }
        }
      } else {
        if (kDebugMode) {
          print("Level document does not exist for: $level");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching flashcards: $e");
      }
    }
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FLASHCARD',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text(
              '${widget.topic.replaceAll('_', ' ').toUpperCase()}.',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _swipeItems.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : SwipeCards(
              matchEngine: _matchEngine,
              itemBuilder: (BuildContext context, int index) {
                Flashcard flashcard = _swipeItems[index].content;

                // ตรวจสอบว่าคำศัพท์ถัดไปจะไม่แสดงความหมายโดยอัตโนมัติ
                bool isNextCard = index == currentIndex + 1;

                return Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: FlashcardItem(
                      flashcard: flashcard,
                      currentIndex: index + 1,
                      totalItems: _swipeItems.length,
                      showMeaning: isShowingMeaning && !isNextCard, // ป้องกันไม่ให้แสดงความหมายของคำถัดไป
                    ),
                  ),
                );
              },
              onStackFinished: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        "เก่งมาก ฉันว่าฉันจำได้แล้ว: $knownCount คำ, ยังจำไม่ได้: $unknownCount คำ"
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  _matchEngine.currentItem?.nope();
                },
              ),
              IconButton(
                icon: const Icon(Icons.mic, color: Colors.blue),
                onPressed: () {
                  final currentItem = _matchEngine.currentItem;
                  if (currentItem != null) {
                    final flashcard = currentItem.content as Flashcard;
                    _speak(flashcard.word);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.backpack, color: Colors.orange),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.message, color: Colors.teal),
                onPressed: () {
                  setState(() {
                    isShowingMeaning = !isShowingMeaning; // สลับแสดงความหมาย
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () {
                  _matchEngine.currentItem?.like();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class FlashcardItem extends StatelessWidget {
  final Flashcard flashcard;
  final int currentIndex;
  final int totalItems;
  final bool showMeaning;

  const FlashcardItem({
    super.key,
    required this.flashcard,
    required this.currentIndex,
    required this.totalItems,
    required this.showMeaning,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 16),
                    Text(
                      showMeaning
                          ? flashcard.definition
                          : flashcard.word,
                      style: const TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  flashcard.partOfSpeech,
                  style: const TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  'ตัวอย่างประโยค :',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  showMeaning
                      ? flashcard.exampleSentence['translation'] ?? ''
                      : flashcard.exampleSentence['sentence'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 35),
                const Text(
                  'คำใบ้ :',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  showMeaning
                      ? flashcard.hintTranslation
                      : flashcard.hint,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$currentIndex of $totalItems',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
