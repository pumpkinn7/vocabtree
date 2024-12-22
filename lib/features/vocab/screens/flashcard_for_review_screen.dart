import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:flutter_tts/flutter_tts.dart';

class FlashcardForReviewScreen extends StatefulWidget {
  final String level;
  final String topic;
  final String userId;
  final List<DocumentSnapshot> vocabDocs;

  const FlashcardForReviewScreen({
    super.key,
    required this.level,
    required this.topic,
    required this.userId,
    required this.vocabDocs,
  });

  @override
  FlashcardForReviewScreenState createState() => FlashcardForReviewScreenState();
}

class FlashcardForReviewScreenState extends State<FlashcardForReviewScreen> {
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
    _prepareFlashcards();
  }

  /// เตรียมข้อมูลจาก [vocabDocs] มาสร้าง SwipeItems
  void _prepareFlashcards() {
    // อ่านข้อมูลจาก DocumentSnapshot แล้ว map เป็น List<Map<String, dynamic>>
    List<Map<String, dynamic>> flashcards = [];
    for (var doc in widget.vocabDocs) {
      final data = doc.data() as Map<String, dynamic>;
      flashcards.add({
        'docId': doc.id,
        'word': data['word'] ?? '',
        'type': data['type'] ?? '',
        'meaning': data['meaning'] ?? '',
        'example_sentence': data['example_sentence'] ?? '',
        'example_translation': data['example_translation'] ?? '',
        'hint': data['hint'] ?? '',
        'hint_translation': data['hint_translation'] ?? '',
      });
    }

    setState(() {
      // สร้าง SwipeItem สำหรับแต่ละ flashcard
      _swipeItems = flashcards.map((f) {
        return SwipeItem(
          content: f,
          // ปัดซ้าย => for_review = true (ยังคงอยู่ใน VocabScreen)
          nopeAction: () {
            _updateForReview(f['docId'], true);
            _resetFlashcardState();
          },
          // ปัดขวา => for_review = false (ลบออกจาก VocabScreen)
          likeAction: () {
            _updateForReview(f['docId'], false);
            _resetFlashcardState();
          },
          // ไม่ต้องมี superlikeAction เพราะเราจะลบปุ่ม superlike ออก
        );
      }).toList();

      // สร้าง MatchEngine สำหรับ SwipeCards
      _matchEngine = MatchEngine(swipeItems: _swipeItems);
    });
  }

  /// รีเซ็ตค่าการแสดงผล Flashcard เมื่อปัดเสร็จ
  void _resetFlashcardState() {
    setState(() {
      isShowingMeaning = false;
      currentIndex++;
    });
  }

  /// อัปเดตค่า `for_review` ใน Firestore ตามผลการปัด
  Future<void> _updateForReview(String docId, bool forReview) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection(widget.level)
        .doc(widget.topic)
        .collection('vocabularies')
        .doc(docId)
        .update({'for_review': forReview});
  }

  /// สั่ง TTS อ่านคำศัพท์
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
              'FLASHCARD (Review)',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text(
              widget.topic.replaceAll('_', ' ').toUpperCase(),
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: _swipeItems.isEmpty
          ? const Center(child: Text('ไม่มีคำศัพท์ใน Topic นี้'))
          : Column(
        children: [
          // ส่วนแสดง Flashcard
          Expanded(
            child: SwipeCards(
              matchEngine: _matchEngine,
              itemBuilder: (BuildContext context, int index) {
                final f = _swipeItems[index].content as Map<String, dynamic>;
                return Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: FlashcardForReviewItem(
                      data: f,
                      currentIndex: index + 1,
                      totalItems: _swipeItems.length,
                      showMeaning: isShowingMeaning,
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
              // ไม่อนุญาตให้ superlike
              upSwipeAllowed: false,
            ),
          ),

          // แถวของปุ่มควบคุมการปัด
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // ปุ่มปัดซ้าย (Nope)
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  _matchEngine.currentItem?.nope();
                },
              ),
              // ปุ่มอ่านออกเสียง
              IconButton(
                icon: const Icon(Icons.volume_up, color: Colors.blue),
                onPressed: () {
                  final currentItem = _matchEngine.currentItem;
                  if (currentItem != null) {
                    final flashcard = currentItem.content as Map<String, dynamic>;
                    _speak(flashcard['word']);
                  }
                },
              ),
              // ปุ่ม toggle แปล / ไม่แปล
              IconButton(
                icon: const Icon(Icons.translate, color: Colors.teal),
                onPressed: () {
                  setState(() {
                    isShowingMeaning = !isShowingMeaning;
                  });
                },
              ),
              // ปุ่มปัดขวา (Like)
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

/// Widget แสดงผลหน้าตา Flashcard รายการเดียว
class FlashcardForReviewItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final int currentIndex;
  final int totalItems;
  final bool showMeaning;

  const FlashcardForReviewItem({
    super.key,
    required this.data,
    required this.currentIndex,
    required this.totalItems,
    required this.showMeaning,
  });

  @override
  Widget build(BuildContext context) {
    final String word = data['word'] ?? '';
    final String type = data['type'] ?? '';
    final String meaning = data['meaning'] ?? '';
    final String sentence = data['example_sentence'] ?? '';
    final String sentenceTrans = data['example_translation'] ?? '';
    final String hint = data['hint'] ?? '';
    final String hintTrans = data['hint_translation'] ?? '';

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
                      // แสดงคำศัพท์ หรือความหมาย
                      Text(
                        showMeaning ? meaning : word,
                        style: const TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // ประเภทคำศัพท์
                      Text(
                        type,
                        style: const TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 25),
                      // ตัวอย่างประโยค
                      const Text(
                        'ตัวอย่างประโยค:',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        showMeaning ? sentenceTrans : sentence,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 35),
                      // คำใบ้
                      const Text(
                        'คำใบ้:',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        showMeaning ? hintTrans : hint,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              // แสดงจำนวน Flashcard (index / total)
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
        ),
      ),
    );
  }
}
