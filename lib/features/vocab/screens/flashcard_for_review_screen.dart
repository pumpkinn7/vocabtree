import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:translator/translator.dart';

import '../../../core/theme/text_styles.dart';
import '../../../features/flashcards/model/flashcard_topic_model.dart';
import '../../../features/flashcards/widgets/flashcard_detail_dialog.dart';
import '../../../features/flashcards/widgets/flashcard_header.dart';
import '../../../features/flashcards/widgets/flashcard_help_dialog.dart';
import '../../../features/flashcards/widgets/flashcard_counter.dart';
import '../../../features/flashcards/widgets/flashcard_loading.dart';
import '../services/review_flashcard_service.dart';
import '../widgets/review_flashcard_item.dart';

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
  State<FlashcardForReviewScreen> createState() =>
      _FlashcardForReviewScreenState();
}

class _FlashcardForReviewScreenState extends State<FlashcardForReviewScreen> {
  final ReviewFlashcardService _service = ReviewFlashcardService();
  final GoogleTranslator _translator = GoogleTranslator();

  late List<SwipeItem> _swipeItems = [];
  late MatchEngine _matchEngine;

  bool _isLoading = true;
  bool _isShowingMeaning = false;
  bool _isShowingThaiTranslation = false;
  bool _isTranslating = false;
  int _currentIndex = 0;

  List<Flashcard> _flashcards = [];
  String _currentTranslation = '';

  @override
  void initState() {
    super.initState();
    // เริ่มดึงข้อมูล
    _prepareFlashcards();
  }

  Future<void> _prepareFlashcards() async {
    setState(() => _isLoading = true);
    _flashcards = [];

    // บันทึกเวลาเริ่มต้น
    final startTime = DateTime.now();

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

    // สร้าง SwipeItems แต่ไม่รวม superlikeAction เพราะเราไม่ใช้การปัดขึ้นในหน้านี้
    if (_flashcards.isNotEmpty) {
      _swipeItems = _flashcards.map((flashcard) {
        return SwipeItem(
          content: flashcard,
          nopeAction: () {
            // itemChanged callback จะจัดการเอง
          },
          likeAction: () async {
            await _service.removeFromReview(
                widget.userId, widget.topic, flashcard.mainWord);
            // itemChanged callback จะจัดการเอง
          },
          // ไม่ต้องมี superlikeAction เพราะเราไม่ใช้การปัดขึ้น
        );
      }).toList();

      _matchEngine = MatchEngine(swipeItems: _swipeItems);
    }

    // คำนวณเวลาที่ใช้ไปแล้ว
    final elapsedTime = DateTime.now().difference(startTime).inMilliseconds;
    final minimumLoadingTime = 3000; // 3 วินาที (3000 มิลลิวินาที)

    // ถ้าใช้เวลาน้อยกว่า 3 วินาที ให้รอจนครบ
    if (elapsedTime < minimumLoadingTime) {
      await Future.delayed(
        Duration(milliseconds: minimumLoadingTime - elapsedTime),
      );
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

  void _toggleThaiTranslation() async {
    if (_matchEngine.currentItem == null) return;

    final flashcard = _matchEngine.currentItem!.content as Flashcard;

    if (_isShowingThaiTranslation) {
      // สลับกลับไปเป็นภาษาอังกฤษ
      setState(() {
        _isShowingThaiTranslation = false;
      });
    } else {
      // สลับไปเป็นภาษาไทย
      setState(() {
        _isTranslating = true;
      });

      try {
        final translation = await _translator.translate(
          flashcard.mainWord,
          from: 'en',
          to: 'th',
        );

        if (mounted) {
          setState(() {
            _currentTranslation = translation.text;
            _isShowingThaiTranslation = true;
            _isTranslating = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _currentTranslation = 'ไม่สามารถแปลได้';
            _isShowingThaiTranslation = true;
            _isTranslating = false;
          });
        }
      }
    }
  }

  void _showWordDetail(Flashcard flashcard) {
    showDialog(
      context: context,
      builder: (context) => FlashcardDetailDialog(flashcard: flashcard),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => const FlashcardHelpDialog(),
    );
  }

  // แสดงข้อความแจ้งเตือนและกลับไปหน้า VocabScreen
  void _showCompletionMessageAndNavigateBack() {
    // แสดง SnackBar เรียบง่ายพร้อมข้อความ
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'คุณได้ทบทวนคำศัพท์ครบทุกคำแล้ว!',
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );

    // กลับไปหน้า VocabScreen หลังจากแสดงข้อความเสร็จ
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pop(context, true);
      }
    });
  }

  @override
  void dispose() {
    _service.flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // สำคัญ: เหมือนกับใน FlashcardScreen
    bootstrapGridParameters(gutterSize: 16);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FlashcardHeader(topic: widget.topic),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.help_outline,
              color: colorScheme.primary,
            ),
            onPressed: _showHelpDialog,
            tooltip: 'วิธีใช้งาน',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_service.getBackgroundImageByLevel(widget.level)),
            fit: BoxFit.cover,
          ),
        ),
        child: _buildContent(colorScheme),
      ),
    );
  }

  Widget _buildContent(ColorScheme colorScheme) {
    if (_isLoading) {
      return const FlashcardLoading();
    }

    if (_flashcards.isEmpty) {
      return Center(
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off, size: 64, color: colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  'ไม่มีคำศัพท์ที่ต้องทบทวน',
                  style: AppTextStyles.subtitle,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Counter
        BootstrapContainer(
          fluid: true,
          children: [
            BootstrapRow(
              children: [
                BootstrapCol(
                  sizes: 'col-xs-10 col-sm-10 col-md-8 col-lg-4',
                  offsets: 'offset-xs-1 offset-sm-1 offset-md-2 offset-lg-4',
                  child: FlashcardCounter(
                    currentIndex: _currentIndex + 1,
                    totalCount: _flashcards.length,
                  ),
                ),
              ],
            ),
          ],
        ),

        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 380,
                child: SwipeCards(
                  matchEngine: _matchEngine,
                  itemBuilder: (BuildContext context, int index) {
                    final flashcard = _flashcards[index];
                    final isNextCard = index == _currentIndex + 1;

                    final bool showThai = !isNextCard &&
                        _isShowingThaiTranslation &&
                        index == _currentIndex;

                    return ReviewFlashcardItem(
                      flashcard: flashcard,
                      currentIndex: index + 1,
                      totalItems: _flashcards.length,
                      showMeaning: _isShowingMeaning && !isNextCard,
                      showThaiTranslation: showThai,
                      thaiTranslation: _currentTranslation,
                      isTranslating: _isTranslating,
                      onDetailPressed: () => _showWordDetail(flashcard),
                    );
                  },
                  onStackFinished: _showCompletionMessageAndNavigateBack,
                  itemChanged: (SwipeItem item, int index) {
                    setState(() {
                      _currentIndex = index;
                      _isShowingMeaning = false;
                      _isShowingThaiTranslation = false;
                    });
                  },
                  upSwipeAllowed: false, // ปิดการปัดขึ้น
                ),
              ),
            ],
          ),
        ),

        // Action Bar
        BootstrapContainer(
          fluid: true,
          children: [
            BootstrapRow(
              children: [
                BootstrapCol(
                  sizes: 'col-xs-12 col-sm-12 col-md-8 col-lg-4',
                  offsets: 'offset-xs-0 offset-sm-0 offset-md-2 offset-lg-4',
                  child: CustomFlashcardActionBar(
                    // ใช้ Custom ActionBar ที่ไม่มีปุ่ม superlike
                    onNopePressed: () => _matchEngine.currentItem?.nope(),
                    onSpeakPressed: () {
                      if (_matchEngine.currentItem != null) {
                        final flashcard =
                            _matchEngine.currentItem!.content as Flashcard;
                        _service.speakWord(flashcard.mainWord);
                      }
                    },
                    onToggleMeaningPressed: _toggleThaiTranslation,
                    onLikePressed: () => _matchEngine.currentItem?.like(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// Action Bar แบบกำหนดเองสำหรับหน้า Review ที่ไม่มีปุ่ม SuperLike
class CustomFlashcardActionBar extends StatelessWidget {
  final VoidCallback onNopePressed;
  final VoidCallback onSpeakPressed;
  final VoidCallback onToggleMeaningPressed;
  final VoidCallback onLikePressed;

  const CustomFlashcardActionBar({
    super.key,
    required this.onNopePressed,
    required this.onSpeakPressed,
    required this.onToggleMeaningPressed,
    required this.onLikePressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: onNopePressed,
            child: Image.asset(
              'assets/images/Flashcard-1.png',
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
          GestureDetector(
            onTap: onSpeakPressed,
            child: Image.asset(
              'assets/images/Flashcard-2.png',
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            ),
          ),
          // ไม่มีปุ่ม SuperLike (Flashcard-3.png)
          GestureDetector(
            onTap: onToggleMeaningPressed,
            child: Image.asset(
              'assets/images/Flashcard-4.png',
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            ),
          ),
          GestureDetector(
            onTap: onLikePressed,
            child: Image.asset(
              'assets/images/Flashcard-5.png',
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
