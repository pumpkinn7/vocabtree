import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:translator/translator.dart';

import '../controllers/flashcard_controller.dart';
import '../model/flashcard_topic_model.dart';
import '../model/swipe_direction.dart';
import '../services/flashcard_service.dart';
import '../repositories/flashcard_repository.dart';
import '../widgets/flashcard_action_bar.dart';
import '../widgets/flashcard_counter.dart';
import '../widgets/flashcard_detail_dialog.dart';
import '../widgets/flashcard_header.dart';
import '../widgets/flashcard_help_dialog.dart';
import '../widgets/flashcard_item.dart';
import '../widgets/flashcard_loading.dart';
import 'flashcard_summary_screen.dart';

class FlashcardScreen extends StatefulWidget {
  final String topic;
  final String userId;

  const FlashcardScreen({
    super.key,
    required this.topic,
    required this.userId,
  });

  @override
  FlashcardScreenState createState() => FlashcardScreenState();
}

class FlashcardScreenState extends State<FlashcardScreen> {
  late FlashcardController _controller;
  bool _isLoading = true;
  bool _isShowingMeaning = false;
  bool _isShowingThaiTranslation = false;
  int _currentIndex = 0;
  List<SwipeItem> _swipeItems = [];
  late MatchEngine _matchEngine;
  final GoogleTranslator _translator = GoogleTranslator();
  String _currentTranslation = '';
  bool _isTranslating = false;

  @override
  void initState() {
    super.initState();

    final flashcardService = FlashcardService();
    final flashcardRepository = FlashcardRepository();

    _controller = FlashcardController(
      service: flashcardService,
      repository: flashcardRepository,
      topic: widget.topic,
      userId: widget.userId,
      updateSwipeItems: (items, engine) => setState(() {
        _swipeItems = items;
        _matchEngine = engine;
      }),
      onNavigateToSummary: _navigateToSummary,
      resetShowMeaning: () => setState(() {
        _isShowingMeaning = false;
      }),
    );

    // เริ่มดึงข้อมูล
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    // บันทึกเวลาเริ่มต้น
    final startTime = DateTime.now();

    // ดึงข้อมูล flashcards
    await _controller.fetchFlashcards();

    // คำนวณเวลาที่ใช้ไปแล้ว
    final elapsedTime = DateTime.now().difference(startTime).inMilliseconds;
    final minimumLoadingTime = 4000; // 4 วินาที (4000 มิลลิวินาที)

    // ถ้าใช้เวลาน้อยกว่า 4 วินาที ให้รอจนครบ
    if (elapsedTime < minimumLoadingTime) {
      await Future.delayed(
        Duration(milliseconds: minimumLoadingTime - elapsedTime),
      );
    }

    // อัพเดทสถานะเมื่อเสร็จสิ้นการโหลด
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // ลบฟังก์ชัน _toggleShowMeaning ที่ไม่ได้ใช้งาน

  // เพิ่มฟังก์ชันใหม่สำหรับสลับภาษา
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

  Future<void> _navigateToSummary() {
    final summaryData = _controller.getSummaryData();
    if (!mounted) return Future.value();

    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => FlashcardSummaryScreen(
          userId: widget.userId,
          topic: widget.topic,
          knownCount: summaryData['knownCount'] ?? 0,
          unknownCount: summaryData['unknownCount'] ?? 0,
          reviewCount: summaryData['reviewCount'] ?? 0,
          totalCount: summaryData['totalCount'] ?? 0,
          sessionUnknownWords:
              List<String>.from(summaryData['sessionUnknownWords'] ?? []),
        ),
      ),
    );
  }

  void _showFlashcardDetail(Flashcard flashcard) {
    showDialog(
      context: context,
      builder: (context) => FlashcardDetailDialog(flashcard: flashcard),
    );
  }

  @override
  void dispose() {
    _controller.flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
            image: AssetImage(_controller.getBackgroundImageByLevel()),
            fit: BoxFit.cover,
          ),
        ),
        child: _buildContent(colorScheme),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => const FlashcardHelpDialog(),
    );
  }

  Widget _buildContent(ColorScheme colorScheme) {
    if (_isLoading) {
      return const FlashcardLoading();
    }

    if (_swipeItems.isEmpty) {
      //ไปยังหน้าสรุปโดยตรงเมื่อไม่มีการ์ด
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToSummary();
      });
      return const Center(
        child: CircularProgressIndicator(),
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
                    totalCount: _swipeItems.length,
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
                  itemBuilder: (context, index) {
                    final flashcard = _swipeItems[index].content as Flashcard;
                    final isNextCard = index == _currentIndex + 1;

                    final bool showThai = !isNextCard &&
                        _isShowingThaiTranslation &&
                        index == _currentIndex;

                    return FlashcardItem(
                      flashcard: flashcard,
                      currentIndex: index + 1,
                      totalItems: _swipeItems.length,
                      showMeaning: _isShowingMeaning && !isNextCard,
                      showThaiTranslation: showThai,
                      thaiTranslation: _currentTranslation,
                      isTranslating: _isTranslating,
                      onDetailPressed: () => _showFlashcardDetail(flashcard),
                    );
                  },
                  onStackFinished: _navigateToSummary,
                  itemChanged: (_, int index) => setState(() {
                    _currentIndex = index;
                    _isShowingMeaning = false;
                    _isShowingThaiTranslation = false;
                  }),
                  upSwipeAllowed: true,
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
                  child: FlashcardActionBar(
                    onNopePressed: () {
                      if (_matchEngine.currentItem != null) {
                        final flashcard =
                            _matchEngine.currentItem!.content as Flashcard;
                        _controller.handleSwipe(flashcard, SwipeDirection.left);
                        _matchEngine.currentItem?.nope();
                      }
                    },
                    onSpeakPressed: () {
                      if (_matchEngine.currentItem != null) {
                        final flashcard =
                            _matchEngine.currentItem!.content as Flashcard;
                        _controller.speakWord(flashcard.mainWord);
                      }
                    },
                    onSuperlikePressed: () {
                      if (_matchEngine.currentItem != null) {
                        final flashcard =
                            _matchEngine.currentItem!.content as Flashcard;
                        _controller.handleSwipe(flashcard, SwipeDirection.up);
                        _matchEngine.currentItem?.superLike();
                      }
                    },
                    onToggleMeaningPressed: _toggleThaiTranslation,
                    onLikePressed: () {
                      if (_matchEngine.currentItem != null) {
                        final flashcard =
                            _matchEngine.currentItem!.content as Flashcard;
                        _controller.handleSwipe(
                            flashcard, SwipeDirection.right);
                        _matchEngine.currentItem?.like();
                      }
                    },
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
