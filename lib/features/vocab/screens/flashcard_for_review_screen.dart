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

    try {
      _flashcards = [];

      // แปลง DocumentSnapshot เป็น Flashcard
      for (var doc in widget.vocabDocs) {
        if (!doc.exists) continue;

        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue;

        // ใช้โครงสร้างตาม Flashcard model
        _flashcards.add(Flashcard(
          id: data['word'] ?? doc.id,
          mainWord: data['word'] ?? doc.id,
          partOfSpeech: data['type'] ?? data['partOfSpeech'] ?? '',
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
            nopeAction: () => setState(() {
              _currentIndex++;
              _isShowingMeaning = false;
            }),
            likeAction: () async {
              await _removeFromReview(flashcard.mainWord);
              setState(() {
                _currentIndex++;
                _isShowingMeaning = false;
              });
            },
          );
        }).toList();

        _matchEngine = MatchEngine(swipeItems: _swipeItems);
      }
    } catch (_) {
      // ไม่ต้องแสดง error
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchFlashcardsFromWordsCollection() async {
    try {
      // ดึงรายการคำศัพท์จาก vocabulary_progress
      final progressDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('vocabulary_progress')
          .doc(widget.topic)
          .get();

      if (!progressDoc.exists || progressDoc.data() == null) return;

      final reviewWordsList =
          List<String>.from(progressDoc.data()!['review_words'] ?? []);
      if (reviewWordsList.isEmpty) return;

      // ดึงข้อมูลจาก words collection
      for (var word in reviewWordsList) {
        try {
          final wordDoc = await FirebaseFirestore.instance
              .collection('words')
              .doc(word)
              .get();

          if (wordDoc.exists && wordDoc.data() != null) {
            final data = wordDoc.data()!;
            _flashcards.add(Flashcard(
              id: word,
              mainWord: data['mainWord'] ?? word,
              partOfSpeech: data['mainPos'] ?? '',
              definition: _extractDefinition(data),
              hint: '',
              cefrLevel: widget.level,
            ));
          }
        } catch (_) {
          // ไม่ต้องแสดง error
        }
      }
    } catch (_) {
      // ไม่ต้องแสดง error
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
    if (mounted) {
      setState(() {
        _currentIndex = index;
        _isShowingMeaning = false;
      });
    }
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
                            // แสดงข้อความเมื่อเล่นจบครบทุกการ์ด
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('คุณได้ทบทวนคำศัพท์ครบทุกคำแล้ว!'),
                              ),
                            );
                          },
                          itemChanged: (SwipeItem item, int index) {
                            _updateCurrentIndex(index);
                          },
                          upSwipeAllowed: false,
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

    // ป้องกันกรณี index เกินขอบเขต
    int safeIndex = _currentIndex;
    if (safeIndex < 0) safeIndex = 0;
    if (safeIndex >= _flashcards.length) safeIndex = _flashcards.length - 1;

    final currentCount = safeIndex + 1;
    final totalCount = _flashcards.length;

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
              '$currentCount of $totalCount',
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
            right: 8, // เปลี่ยนจาก left เป็น right
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
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // ประเภทคำศัพท์
                  Text(
                    flashcard.partOfSpeech,
                    style: const TextStyle(
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
