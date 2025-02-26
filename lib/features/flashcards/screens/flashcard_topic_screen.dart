import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';

import '../controllers/flashcard_controller.dart';
import '../model/flashcard_topic_model.dart';
import '../model/swipe_direction.dart';
import '../widgets/flashcard_action_bar.dart';
import '../widgets/flashcard_detail_dialog.dart';
import '../widgets/flashcard_header.dart';
import '../widgets/flashcard_item.dart';
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
    final summaryData = await _controller.getSummaryData();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => FlashcardSummaryScreen(
          userId: widget.userId,
          topic: widget.topic,
          knownCount: summaryData['knownCount'] ?? 0,
          reviewCount: summaryData['reviewCount'] ?? 0,
          unknownCount: summaryData['unknownCount'] ?? 0,
          totalCount: summaryData['totalCount'] ?? 0,
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

  void _incrementCurrentIndex() {
    setState(() {
      _currentIndex++;
      _isShowingMeaning = false;
    });
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
        // Counter is positioned here, above the card
        _buildCounter(),
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
                onDetailPressed: () => _showFlashcardDetail(flashcard),
              );
            },
            onStackFinished: _navigateToSummary,
            itemChanged: (_, int index) => setState(() {
              _currentIndex = index;
              _isShowingMeaning = false;
            }),
            upSwipeAllowed: true,
          ),
        ),
        FlashcardActionBar(
          onNopePressed: () {
            if (_matchEngine.currentItem != null) {
              final flashcard = _matchEngine.currentItem!.content as Flashcard;
              _controller.handleSwipe(flashcard, SwipeDirection.left);
              _matchEngine.currentItem?.nope();
              _incrementCurrentIndex();
            }
          },
          onSpeakPressed: () {
            if (_matchEngine.currentItem != null) {
              final flashcard = _matchEngine.currentItem!.content as Flashcard;
              _controller.speakWord(flashcard.mainWord);
            }
          },
          onSuperlikePressed: () {
            if (_matchEngine.currentItem != null) {
              final flashcard = _matchEngine.currentItem!.content as Flashcard;
              _controller.handleSwipe(flashcard, SwipeDirection.up);
              _matchEngine.currentItem?.superLike();
              _incrementCurrentIndex();
            }
          },
          onToggleMeaningPressed: _toggleShowMeaning,
          onLikePressed: () {
            if (_matchEngine.currentItem != null) {
              final flashcard = _matchEngine.currentItem!.content as Flashcard;
              _controller.handleSwipe(flashcard, SwipeDirection.right);
              _matchEngine.currentItem?.like();
              _incrementCurrentIndex();
            }
          },
        ),
      ],
    );
  }

  Widget _buildCounter() {
    if (_swipeItems.isEmpty) return const SizedBox.shrink();

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
              '${_currentIndex + 1} of ${_swipeItems.length}',
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
}
