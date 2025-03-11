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
  final Function(List<SwipeItem>, MatchEngine) updateSwipeItems;
  final Function() onNavigateToSummary;
  final Function() resetShowMeaning;

  // ตัวแปรเก็บสถิติ
  int _knownCount = 0;
  int _unknownCount = 0;
  int _reviewCount = 0;
  int _totalCount = 0;

  // เปลี่ยนจาก List เป็น Set เพื่อป้องกันการซ้ำ
  final Set<String> _sessionUnknownWords = {};

  List<SwipeItem> swipeItems = [];
  late MatchEngine matchEngine;

  FlashcardController({
    required this.topic,
    required this.userId,
    required this.updateSwipeItems,
    required this.onNavigateToSummary,
    required this.resetShowMeaning,
  })  : service = FlashcardService(),
        flutterTts = FlutterTts();

  /// ดึงข้อมูล flashcards
  Future<void> fetchFlashcards() async {
    try {
      // รีเซ็ตตัวนับ
      _knownCount = 0;
      _unknownCount = 0;
      _reviewCount = 0;
      _sessionUnknownWords.clear(); // ล้างรายการคำศัพท์ที่ไม่รู้เมื่อเริ่มใหม่

      List<Flashcard> flashcards = await service.getFlashcardsForTopic(topic);

      Map<String, List<String>> statuses =
          await service.getWordStatuses(userId, topic);
      List<String> knownWords = statuses['known_words'] ?? [];

      List<Flashcard> filteredFlashcards = flashcards
          .where((flashcard) => !knownWords.contains(flashcard.id))
          .toList();

      filteredFlashcards.shuffle();

      _totalCount = filteredFlashcards.length;

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

      // หากไม่มีการ์ด ให้นำทางไปหน้าสรุปทันที
      if (swipeItems.isEmpty) {
        onNavigateToSummary();
      }
    } catch (e) {
      AppLogger.e(_tag, 'เกิดข้อผิดพลาดในการดึงข้อมูล flashcards', e);
      // กรณีเกิดข้อผิดพลาด ให้นำทางไปหน้าสรุปเช่นกัน
      onNavigateToSummary();
    }
  }

  /// จัดการการปัดการ์ด
  Future<void> handleSwipe(
      Flashcard flashcard, SwipeDirection direction) async {
    try {
      // อัพเดทตัวนับ
      if (direction == SwipeDirection.right) {
        _knownCount++;
      } else if (direction == SwipeDirection.left) {
        _unknownCount++;
        // เพิ่มคำที่ไม่รู้ในรอบนี้ (เป็น Set จึงไม่เก็บคำซ้ำ)
        _sessionUnknownWords.add(flashcard.id);
      } else if (direction == SwipeDirection.up) {
        _reviewCount++;
      }

      await service.saveWordStatus(
        userId,
        topic,
        flashcard.id,
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
    switch (topic.substring(0, 2)) {
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
  Future<Map<String, dynamic>> getSummaryData() async {
    // แปลง Set เป็น List ก่อนส่งออกไป
    return {
      'knownCount': _knownCount,
      'unknownCount': _unknownCount,
      'reviewCount': _reviewCount,
      'totalCount': _totalCount,
      'sessionUnknownWords': _sessionUnknownWords.toList(),
    };
  }

  /// เคลียร์ทรัพยากร
  void dispose() {
    flutterTts.stop();
  }
}
