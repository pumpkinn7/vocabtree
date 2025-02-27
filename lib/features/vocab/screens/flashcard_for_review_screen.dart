import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:swipe_cards/swipe_cards.dart';

import '../../../features/flashcards/model/flashcard_topic_model.dart';
import '../../../features/flashcards/widgets/flashcard_detail_dialog.dart';
import '../../../features/flashcards/widgets/flashcard_header.dart';

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
  FlashcardForReviewScreenState createState() =>
      FlashcardForReviewScreenState();
}

class FlashcardForReviewScreenState extends State<FlashcardForReviewScreen> {
  final FlutterTts flutterTts = FlutterTts();

  late List<SwipeItem> _swipeItems = [];
  late MatchEngine _matchEngine;
  bool _isLoading = true;
  bool _isShowingMeaning = false;
  int _currentIndex = 0;
  List<Flashcard> _flashcards = [];

  @override
  void initState() {
    super.initState();
    _prepareFlashcards();
  }

  Future<void> _prepareFlashcards() async {
    setState(() => _isLoading = true);
    _flashcards = [];

    // แปลง DocumentSnapshot เป็น Flashcard
    for (var doc in widget.vocabDocs) {
      if (!doc.exists) continue;

      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) continue;

      final partOfSpeech = data['type']?.toString() ??
          data['partOfSpeech']?.toString() ??
          data['mainPos']?.toString() ??
          '';

      _flashcards.add(Flashcard(
        id: data['word'] ?? doc.id,
        mainWord: data['word'] ?? doc.id,
        partOfSpeech: partOfSpeech,
        definition: data['definition'] ?? data['meaning'] ?? 'No definition',
        hint: '',
        cefrLevel: data['cefrLevel'] ?? widget.level,
      ));
    }

    // ถ้ายังไม่มี flashcards ลองดึงจาก words collection
    if (_flashcards.isEmpty) {
      await _fetchFlashcardsFromWordsCollection();
    }

    // สร้าง SwipeItems
    if (_flashcards.isNotEmpty) {
      _swipeItems = _flashcards.map((flashcard) {
        return SwipeItem(
          content: flashcard,
          nopeAction: () {
            // ไม่ต้องเรียกเพิ่ม index ที่นี่
            // _currentIndex จะถูกอัพเดทผ่าน itemChanged callback แล้ว
          },
          likeAction: () async {
            await _removeFromReview(flashcard.mainWord);
            // ไม่ต้องเรียกเพิ่ม index ที่นี่
          },
        );
      }).toList();

      _matchEngine = MatchEngine(swipeItems: _swipeItems);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchFlashcardsFromWordsCollection() async {
    final progressDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('vocabulary_progress')
        .doc(widget.topic)
        .get();

    if (!progressDoc.exists) return;

    final reviewWordsList =
        List<String>.from(progressDoc.data()?['review_words'] ?? []);
    if (reviewWordsList.isEmpty) return;

    for (var word in reviewWordsList) {
      final wordDoc =
          await FirebaseFirestore.instance.collection('words').doc(word).get();

      if (!wordDoc.exists) continue;

      final data = wordDoc.data()!;
      final String partOfSpeech;

      if (data['mainPos']?.toString().isNotEmpty ?? false) {
        partOfSpeech = data['mainPos'];
      } else if (data['senses'] is List &&
          (data['senses'] as List).isNotEmpty) {
        final firstSense = (data['senses'] as List).first;
        partOfSpeech = firstSense['partOfSpeech']?.toString() ?? '';
      } else {
        partOfSpeech = '';
      }

      _flashcards.add(Flashcard(
        id: word,
        mainWord: data['mainWord'] ?? word,
        partOfSpeech: partOfSpeech,
        definition: _extractDefinition(data),
        hint: '',
        cefrLevel: widget.level,
      ));
    }
  }

  String _extractDefinition(Map<String, dynamic> data) {
    if (data['senses'] is List && (data['senses'] as List).isNotEmpty) {
      final firstSense = (data['senses'] as List).first;
      if (firstSense is Map<String, dynamic> &&
          firstSense['definition'] != null) {
        return firstSense['definition'];
      }
    }
    return 'No definition';
  }

  /// ลบคำออกจาก review_words array
  Future<void> _removeFromReview(String word) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('vocabulary_progress')
          .doc(widget.topic)
          .update({
        'review_words': FieldValue.arrayRemove([word])
      });
    } catch (_) {
      // ไม่ต้องแสดง error
    }
  }

  /// สั่ง TTS อ่านคำศัพท์
  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  void _toggleShowMeaning() {
    setState(() {
      _isShowingMeaning = !_isShowingMeaning;
    });
  }

  void _showWordDetail(Flashcard flashcard) {
    showDialog(
      context: context,
      builder: (context) => FlashcardDetailDialog(flashcard: flashcard),
    );
  }

  // ตรวจสอบให้แน่ใจว่าชื่อไฟล์ถูกต้อง (และไม่มี path issues)
  String _getBackgroundImageByLevel() {
    return 'assets/images/flashcard_bg.png';
  }

  void _updateCurrentIndex(int index) {
    if (!mounted) return;
    setState(() {
      _currentIndex = index;
      _isShowingMeaning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FlashcardHeader(topic: widget.topic),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_getBackgroundImageByLevel()),
            fit: BoxFit.cover,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _flashcards.isEmpty
                ? const Center(
                    child: Text(
                    'ไม่มีคำศัพท์ใน Topic นี้',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ))
                : Column(
                    children: [
                      // ส่วนแสดงจำนวน Flashcard
                      _buildCounter(),

                      // ส่วนแสดง Flashcard
                      Expanded(
                        child: SwipeCards(
                          matchEngine: _matchEngine,
                          itemBuilder: (BuildContext context, int index) {
                            final flashcard = _flashcards[index];
                            return Center(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.85,
                                height:
                                    MediaQuery.of(context).size.height * 0.65,
                                child: _buildFlashcardItem(flashcard),
                              ),
                            );
                          },
                          onStackFinished: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('คุณได้ทบทวนคำศัพท์ครบทุกคำแล้ว!'),
                              ),
                            );
                          },
                          itemChanged: (SwipeItem item, int index) {
                            // แก้ไขตรงนี้ ใช้ตัวแปร index โดยตรงจาก callback
                            setState(() {
                              _currentIndex = index;
                              _isShowingMeaning = false;
                            });
                          },
                        ),
                      ),

                      // แถวของปุ่มควบคุมการปัด
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // ปุ่มปัดซ้าย (ยังต้องการทบทวน)
                          IconButton(
                            icon: Icon(Icons.close,
                                color: Colors.red.withOpacity(0.8), size: 32),
                            onPressed: () {
                              _matchEngine.currentItem?.nope();
                              // ไม่ต้องเรียก _updateCurrentIndex เพิ่มเติม
                            },
                          ),
                          // ปุ่มอ่านออกเสียง
                          IconButton(
                            icon: Icon(Icons.volume_up,
                                color: Colors.blue.withOpacity(0.8), size: 32),
                            onPressed: () {
                              final currentItem = _matchEngine.currentItem;
                              if (currentItem != null) {
                                final flashcard =
                                    currentItem.content as Flashcard;
                                _speak(flashcard.mainWord);
                              }
                            },
                          ),
                          // ปุ่ม toggle แปล / ไม่แปล
                          IconButton(
                            icon: Icon(
                              _isShowingMeaning
                                  ? Icons.g_translate
                                  : Icons.translate,
                              color: Colors.teal.withOpacity(0.8),
                              size: 32,
                            ),
                            onPressed: _toggleShowMeaning,
                          ),
                          // ปุ่มปัดขวา (รู้จักแล้ว - ไม่ต้องทบทวนอีก)
                          IconButton(
                            icon: Icon(Icons.check,
                                color: Colors.green.withOpacity(0.8), size: 32),
                            onPressed: () {
                              _matchEngine.currentItem?.like();
                              // ไม่ต้องเรียก _updateCurrentIndex เพิ่มเติม
                            },
                          ),
                        ],
                      ),

                      // เพิ่มช่องว่างด้านล่าง
                      const SizedBox(height: 20),
                    ],
                  ),
      ),
    );
  }

  Widget _buildCounter() {
    if (_flashcards.isEmpty) return const SizedBox.shrink();

    // ใช้ currentIndex โดยตรง ไม่ต้องป้องกันเกินขอบเขต
    // เพราะ SwipeCards จะจัดการให้เราอยู่แล้ว
    final currentCount = _currentIndex + 1;
    final totalCount = _flashcards.length;

    // ถ้า currentCount เกิน totalCount ให้แสดงค่าสุดท้าย
    final displayCount = currentCount > totalCount ? totalCount : currentCount;

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.only(
            right: MediaQuery.of(context).size.width * 0.075,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$displayCount of $totalCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlashcardItem(Flashcard flashcard) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // ปุ่มดูรายละเอียดย้ายไปทางขวา
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.blue),
              onPressed: () => _showWordDetail(flashcard),
            ),
          ),

          // เนื้อหาหลัก
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // แสดงคำศัพท์ หรือความหมาย
                  Text(
                    _isShowingMeaning
                        ? flashcard.definition
                        : flashcard.mainWord,
                    style: const TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // ประเภทคำศัพท์ (แสดงเฉพาะเมื่อไม่ได้แสดงความหมาย)
                  if (!_isShowingMeaning && flashcard.partOfSpeech.isNotEmpty)
                    Text(
                      flashcard.partOfSpeech,
                      style: const TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
