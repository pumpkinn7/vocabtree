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

  /// เลือกภาพพื้นหลังตามระดับ CEFR
  String _getBackgroundImage() {
    String topic = widget.topic;
    String cefrLevel = _getCefrLevelFromTopic(topic);

    switch (cefrLevel) {
      case 'B1':
        return 'assets/images/spring.png';
      case 'B2':
        return 'assets/images/summer.png';
      case 'C1':
        return 'assets/images/autumn.png';
      case 'C2':
        return 'assets/images/winter.png';
      default:
        return 'assets/images/spring.png';
    }
  }

  /// ตรวจสอบระดับ CEFR จากชื่อ topic
  String _getCefrLevelFromTopic(String topic) {
    // 1. ตรวจสอบถ้า topic เริ่มต้นด้วย B1_, B2_, C1_, C2_
    if (topic.startsWith('B1_')) return 'B1';
    if (topic.startsWith('B2_')) return 'B2';
    if (topic.startsWith('C1_')) return 'C1';
    if (topic.startsWith('C2_')) return 'C2';

    // 2. ตรวจสอบจากฐานข้อมูลของ topics ที่รู้จัก
    final Map<String, List<String>> knownTopics = {
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

    // ตรวจสอบว่า topic อยู่ในระดับใด
    for (var entry in knownTopics.entries) {
      if (entry.value.contains(topic)) {
        return entry.key;
      }
    }

    // 3. ถ้าไม่พบในรายการที่รู้จัก ตรวจสอบจาก 2 ตัวอักษรแรก
    if (topic.length >= 2) {
      String prefix = topic.substring(0, 2).toUpperCase();
      if (['B1', 'B2', 'C1', 'C2'].contains(prefix)) {
        return prefix;
      }
    }

    return 'B1'; // ค่าเริ่มต้น
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
            image: AssetImage(_getBackgroundImage()),
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
