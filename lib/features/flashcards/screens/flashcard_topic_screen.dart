import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';

import '../controllers/flashcard_controller.dart';
import '../model/flashcard_topic_model.dart';
import '../widgets/widgets.dart';
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
  int _currentIndex = 0;
  List<SwipeItem> _swipeItems = [];
  late MatchEngine _matchEngine;

  @override
  void initState() {
    super.initState();
    _controller = FlashcardController(
      topic: widget.topic,
      userId: widget.userId,
      updateLoadingState: (isLoading) => setState(() => _isLoading = isLoading),
      updateSwipeItems: (items, engine) => setState(() {
        _swipeItems = items;
        _matchEngine = engine;
      }),
      onNavigateToSummary: _navigateToSummary,
      resetShowMeaning: () => setState(() {
        _isShowingMeaning = false;
        _currentIndex++;
      }),
    );

    // เริ่มดึงข้อมูล
    _controller.fetchFlashcards();
  }

  void _toggleShowMeaning() {
    setState(() {
      _isShowingMeaning = !_isShowingMeaning;
    });
  }

  Future<void> _navigateToSummary() async {
    // ดึงข้อมูลสำหรับหน้าสรุป
    final summaryData = await _controller.getSummaryData();
    if (!mounted) return;

    final level = _controller.service.getLevelFromCategory(widget.topic);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => FlashcardSummaryScreen(
          userId: widget.userId,
          topic: widget.topic,
          level: level,
          knownCount: summaryData['knownCount'] ?? 0,
          reviewCount: summaryData['reviewCount'] ?? 0,
          unknownCount: summaryData['unknownCount'] ?? 0,
          totalCount: summaryData['totalCount'] ?? 0,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FlashcardHeader(topic: widget.topic),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_controller.getBackgroundImageByLevel()),
            fit: BoxFit.cover,
          ),
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_swipeItems.isEmpty) {
      return const Center(child: Text('ไม่มีคำศัพท์ให้เรียน'));
    }

    return Column(
      children: [
        Expanded(
          child: SwipeCards(
            matchEngine: _matchEngine,
            itemBuilder: (context, index) {
              final flashcard = _swipeItems[index].content as Flashcard;
              final isNextCard = index == _currentIndex + 1;

              return FlashcardItem(
                flashcard: flashcard,
                currentIndex: index + 1,
                totalItems: _swipeItems.length,
                showMeaning: _isShowingMeaning && !isNextCard,
              );
            },
            onStackFinished: _navigateToSummary,
            itemChanged: (_, __) => setState(() => _isShowingMeaning = false),
            upSwipeAllowed: true,
          ),
        ),
        FlashcardActionBar(
          onNopePressed: () => _matchEngine.currentItem?.nope(),
          onSpeakPressed: () {
            if (_matchEngine.currentItem != null) {
              final flashcard = _matchEngine.currentItem!.content as Flashcard;
              _controller.speakWord(flashcard.word);
            }
          },
          onSuperlikePressed: () => _matchEngine.currentItem?.superLike(),
          onToggleMeaningPressed: _toggleShowMeaning,
          onLikePressed: () => _matchEngine.currentItem?.like(),
        ),
      ],
    );
  }
}
