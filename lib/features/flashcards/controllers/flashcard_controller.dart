import 'package:flutter_tts/flutter_tts.dart';
import 'package:swipe_cards/swipe_cards.dart';

import '../../../utils/app_logger.dart';
import '../model/flashcard_topic_model.dart';
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
      // ดึงคำศัพท์
      List<Flashcard> flashcards = await service.getFlashcardsForTopic(topic);

      // ดึงคำที่รู้แล้ว
      List<String> knownWords = await service.getUserKnownWords(userId, topic);

      // กรองและสุ่มคำศัพท์
      List<Flashcard> filteredFlashcards = flashcards
          .where((flashcard) => !knownWords.contains(flashcard.word))
          .toList();

      filteredFlashcards.shuffle();

      // สร้าง swipe items
      swipeItems = filteredFlashcards.map((flashcard) {
        return SwipeItem(
          content: flashcard,
          likeAction: () {
            saveFlashcardStatus(flashcard, true, false);
            resetShowMeaning();
          },
          nopeAction: () {
            saveFlashcardStatus(flashcard, false, false);
            resetShowMeaning();
          },
          superlikeAction: () {
            saveFlashcardStatus(flashcard, true, true);
            resetShowMeaning();
          },
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

  /// บันทึกสถานะของ flashcard
  Future<void> saveFlashcardStatus(
      Flashcard flashcard, bool isKnown, bool forReview) async {
    try {
      await service.saveUserFlashcardStatus(
          userId, topic, flashcard, isKnown, forReview);
    } catch (e) {
      AppLogger.e(_tag, 'เกิดข้อผิดพลาดในการบันทึกสถานะ flashcard', e);
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
    final knownCount = await service.countKnownWords(userId, topic);
    final reviewCount = await service.countReviewWords(userId, topic);
    final unknownCount = await service.countUnknownWords(userId, topic);
    final totalCount = knownCount + reviewCount + unknownCount;

    return {
      'knownCount': knownCount,
      'reviewCount': reviewCount,
      'unknownCount': unknownCount,
      'totalCount': totalCount,
    };
  }

  /// เคลียร์ทรัพยากร
  void dispose() {
    flutterTts.stop();
  }
}
