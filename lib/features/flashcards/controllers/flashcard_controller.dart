import 'package:flutter_tts/flutter_tts.dart';
import 'package:swipe_cards/swipe_cards.dart';

import '../../../utils/app_logger.dart';
import '../model/flashcard_topic_model.dart';
import '../model/swipe_direction.dart';
import '../services/flashcard_service.dart';

/// คลาสควบคุมการทำงานของ flashcards
class FlashcardController {
  static const String _tag = 'FlashcardController';

  final String topic;
  final String userId;
  final FlashcardService service;
  final FlutterTts flutterTts;
  final Function(bool) updateLoadingState;
  final Function(List<SwipeItem>, MatchEngine) updateSwipeItems;
  final Function() onNavigateToSummary;
  final Function() resetShowMeaning;

  List<SwipeItem> swipeItems = [];
  late MatchEngine matchEngine;

  FlashcardController({
    required this.topic,
    required this.userId,
    required this.updateLoadingState,
    required this.updateSwipeItems,
    required this.onNavigateToSummary,
    required this.resetShowMeaning,
  })  : service = FlashcardService(),
        flutterTts = FlutterTts();

  /// ดึงข้อมูล flashcards
  Future<void> fetchFlashcards() async {
    updateLoadingState(true);

    try {
      List<Flashcard> flashcards = await service.getFlashcardsForTopic(topic);

      Map<String, List<String>> statuses =
          await service.getWordStatuses(userId, topic);
      List<String> knownWords = statuses['known_words'] ?? [];

      List<Flashcard> filteredFlashcards = flashcards
          .where((flashcard) => !knownWords.contains(flashcard.id))
          .toList();

      filteredFlashcards.shuffle();

      swipeItems = filteredFlashcards.map((flashcard) {
        return SwipeItem(
          content: flashcard,
          likeAction: () => handleSwipe(flashcard, SwipeDirection.right),
          nopeAction: () => handleSwipe(flashcard, SwipeDirection.left),
          superlikeAction: () => handleSwipe(flashcard, SwipeDirection.up),
        );
      }).toList();

      matchEngine = MatchEngine(swipeItems: swipeItems);
      updateSwipeItems(swipeItems, matchEngine);

      if (swipeItems.isEmpty) {
        onNavigateToSummary();
      }
    } catch (e) {
      AppLogger.e(_tag, 'เกิดข้อผิดพลาดในการดึงข้อมูล flashcards', e);
    } finally {
      updateLoadingState(false);
    }
  }

  /// จัดการการปัดการ์ด
  Future<void> handleSwipe(
      Flashcard flashcard, SwipeDirection direction) async {
    try {
      await service.saveWordStatus(
        userId,
        topic,
        flashcard.id, // เปลี่ยนจาก flashcard.word เป็น flashcard.id
        direction,
      );
      resetShowMeaning();
    } catch (e) {
      AppLogger.e(_tag, 'เกิดข้อผิดพลาดในการบันทึกสถานะคำศัพท์', e);
    }
  }

  /// อ่านออกเสียงคำศัพท์
  Future<void> speakWord(String text) async {
    await flutterTts.speak(text);
  }

  /// หาภาพพื้นหลังตามระดับ
  String getBackgroundImageByLevel() {
    String level = service.getLevelFromCategory(topic);
    switch (level) {
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

  /// เตรียมข้อมูลสำหรับหน้าสรุป
  Future<Map<String, int>> getSummaryData() async {
    final statuses = await service.getWordStatuses(userId, topic);

    return {
      'knownCount': statuses['known_words']?.length ?? 0,
      'unknownCount': statuses['unknown_words']?.length ?? 0,
      'reviewCount': statuses['review_words']?.length ?? 0,
      'totalCount': (statuses['known_words']?.length ?? 0) +
          (statuses['unknown_words']?.length ?? 0) +
          (statuses['review_words']?.length ?? 0),
    };
  }

  /// เคลียร์ทรัพยากร
  void dispose() {
    flutterTts.stop();
  }
}
