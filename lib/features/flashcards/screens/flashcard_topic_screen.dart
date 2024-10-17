import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swipe_cards/swipe_cards.dart';

import '../model/flashcard_topic_model.dart';

class FlashcardScreen extends StatefulWidget {
  final String topic;
  final String userId;

  const FlashcardScreen({super.key, required this.topic, required this.userId});

  @override
  FlashcardScreenState createState() => FlashcardScreenState();
}

class FlashcardScreenState extends State<FlashcardScreen> {
  late List<SwipeItem> _swipeItems;
  late MatchEngine _matchEngine;
  final FlutterTts flutterTts = FlutterTts();
  bool isShowingMeaning = false;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _swipeItems = [];
    _matchEngine = MatchEngine(swipeItems: _swipeItems);
    _fetchFlashcards();
  }

  Future<void> _fetchFlashcards() async {
    String level = _getLevelFromTopic(widget.topic);

    DocumentSnapshot levelSnapshot = await FirebaseFirestore.instance
        .collection('cefr_levels')
        .doc(level)
        .get();

    Map<String, dynamic> topics =
    (levelSnapshot.data() as Map<String, dynamic>)['topics'];

    List<dynamic> vocabularies =
    topics[widget.topic]['vocabularies'] as List<dynamic>;

    QuerySnapshot userKnownVocabSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection(level)
        .doc(widget.topic)
        .collection('vocabularies')
        .where('is_known', isEqualTo: true)
        .get();

    List<String> knownWords = [];
    for (var doc in userKnownVocabSnapshot.docs) {
      knownWords.add(doc.id);
    }

    List<dynamic> filteredVocabularies = vocabularies
        .where((vocab) => !knownWords.contains(vocab['word']))
        .toList();

    filteredVocabularies.shuffle();

    setState(() {
      _swipeItems = filteredVocabularies.map((vocab) {
        Flashcard flashcard = Flashcard.fromMap(vocab);
        return SwipeItem(
          content: flashcard,
          likeAction: () {
            _saveFlashcardToFirestore(flashcard, true, false);
            _resetFlashcardState();
          },
          nopeAction: () {
            _saveFlashcardToFirestore(flashcard, false, false);
            _resetFlashcardState();
          },
          superlikeAction: () {
            _saveFlashcardToFirestore(flashcard, true, true);
            _resetFlashcardState();
          },
        );
      }).toList();
      _matchEngine = MatchEngine(swipeItems: _swipeItems);
    });
  }

  void _resetFlashcardState() {
    setState(() {
      isShowingMeaning = false;
      currentIndex++;
    });
  }

  String _getLevelFromTopic(String topic) {
    if (topic.startsWith('daily_life') ||
        topic.startsWith('education') ||
        topic.startsWith('entertainment') ||
        topic.startsWith('environment_and_nature') ||
        topic.startsWith('health_and_fitness') ||
        topic.startsWith('travel_and_tourism')) {
      return 'B1';
    } else if (topic.startsWith('home_renovation_and_decor') ||
        topic.startsWith('outdoor_activities_and_adventures') ||
        topic.startsWith('music_and_performing_arts') ||
        topic.startsWith('fitness_and_exercise') ||
        topic.startsWith('cooking_and_culinary_skills') ||
        topic.startsWith('pet_care_and_animal_welfare') ||
        topic.startsWith('gardening_and_landscaping') ||
        topic.startsWith('hobbies_and_crafts')) {
      return 'B2';
    } else if (topic.startsWith('urban_living') ||
        topic.startsWith('digital_well_being') ||
        topic.startsWith('cultural_festivals') ||
        topic.startsWith('creative_writing') ||
        topic.startsWith('nutrition_and_wellness') ||
        topic.startsWith('interior_decorating') ||
        topic.startsWith('fashion_trends') ||
        topic.startsWith('event_planning')) {
      return 'C1';
    } else if (topic.startsWith('immersive_technologies') ||
        topic.startsWith('cosmic_discoveries') ||
        topic.startsWith('digital_finance') ||
        topic.startsWith('adrenaline_activities') ||
        topic.startsWith('smart_automation') ||
        topic.startsWith('legends_and_lore') ||
        topic.startsWith('criminal_investigation')) {
      return 'C2';
    } else {
      return 'B1';
    }
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  Future<void> _saveFlashcardToFirestore(
      Flashcard flashcard, bool isKnown, bool forReview) async {
    String userId = widget.userId;
    String level = _getLevelFromTopic(widget.topic);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection(level)
        .doc(widget.topic)
        .collection('vocabularies')
        .doc(flashcard.word)
        .set({
      'userId': userId,
      'level': level,
      'topic': widget.topic,
      'word': flashcard.word,
      'is_known': isKnown,
      'for_review': forReview,
      'meaning': flashcard.definition,
      'type': flashcard.partOfSpeech,
      'example_sentence': flashcard.exampleSentence['sentence'] ?? '',
      'example_translation': flashcard.exampleSentence['translation'] ?? '',
      'hint': flashcard.hint,
      'hint_translation': flashcard.hintTranslation,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
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
      body: _swipeItems.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: SwipeCards(
              matchEngine: _matchEngine,
              itemBuilder: (BuildContext context, int index) {
                Flashcard flashcard = _swipeItems[index].content;

                bool isNextCard = index == currentIndex + 1;

                return Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: FlashcardItem(
                      flashcard: flashcard,
                      currentIndex: index + 1,
                      totalItems: _swipeItems.length,
                      showMeaning: isShowingMeaning && !isNextCard,
                    ),
                  ),
                );
              },
              onStackFinished: () {},
              itemChanged: (SwipeItem item, int index) {
                setState(() {
                  isShowingMeaning = false;
                });
              },
              upSwipeAllowed: true,
            ),
          ),
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
                icon: const Icon(Icons.volume_up, color: Colors.blue),
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
                onPressed: () {
                  _matchEngine.currentItem?.superLike();
                },
              ),
              IconButton(
                icon: const Icon(Icons.translate, color: Colors.teal),
                onPressed: () {
                  setState(() {
                    isShowingMeaning = !isShowingMeaning;
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
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        showMeaning ? flashcard.definition : flashcard.word,
                        style: const TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
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
                        'ตัวอย่างประโยค: ',
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
                        'คำใบ้: ',
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
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        ),
      ),
    );
  }
}
