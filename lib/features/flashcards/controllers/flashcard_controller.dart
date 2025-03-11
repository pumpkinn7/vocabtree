import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:swipe_cards/swipe_cards.dart';

import '../../../utils/app_logger.dart';
import '../model/swipe_direction.dart';
import '../repositories/flashcard_repository.dart';
import '../services/flashcard_service.dart';
import '../model/flashcard_topic_model.dart';

class FlashcardController {
  static const String _tag = 'FlashcardController';
  final FlutterTts flutterTts = FlutterTts();

  final FlashcardService service;
  final FlashcardRepository repository;
  final String userId;
  final String topic;
  final Function(List<SwipeItem>, MatchEngine) updateSwipeItems;
  final VoidCallback onNavigateToSummary;
  final VoidCallback resetShowMeaning;

  List<SwipeItem> swipeItems = [];
  MatchEngine? matchEngine;

  int _totalCount = 0;
  int get totalCount => _totalCount;

  // เก็บค่าสำหรับแสดงในหน้าสรุป
  final Set<String> _sessionKnownWords = {};
  final Set<String> _sessionUnknownWords = {};
  final Set<String> _sessionReviewWords = {};

  FlashcardController({
    required this.service,
    required this.repository,
    required this.userId,
    required this.topic,
    required this.updateSwipeItems,
    required this.onNavigateToSummary,
    required this.resetShowMeaning,
  });

  /// ดึงข้อมูล flashcards
  Future<void> fetchFlashcards() async {
    try {
      // รีเซ็ตตัวนับ
      _sessionKnownWords.clear();
      _sessionUnknownWords.clear();
      _sessionReviewWords.clear();

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

      if (matchEngine != null) {
        updateSwipeItems(swipeItems, matchEngine!);
      } else {
        matchEngine = MatchEngine(swipeItems: swipeItems);
        updateSwipeItems(swipeItems, matchEngine!);
      }

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
    final mainWord = flashcard.mainWord;

    // ลบคำออกจาก set อื่นๆ ก่อน (กรณีผู้ใช้เคยปัดคำนี้แล้ว)
    _sessionKnownWords.remove(mainWord);
    _sessionUnknownWords.remove(mainWord);
    _sessionReviewWords.remove(mainWord);

    // เพิ่มลง set ตามทิศทางที่ปัด
    switch (direction) {
      case SwipeDirection.right: // รู้จักแล้ว
        _sessionKnownWords.add(mainWord);
        await repository.saveUserFlashcardStatus(
            userId, topic, flashcard, true, false);
        break;
      case SwipeDirection.left: // ไม่รู้จัก
        _sessionUnknownWords.add(mainWord);
        await repository.saveUserFlashcardStatus(
            userId, topic, flashcard, false, false);
        break;
      case SwipeDirection.up: // ต้องทบทวน
        _sessionReviewWords.add(mainWord);
        await repository.saveUserFlashcardStatus(
            userId, topic, flashcard, false, true);
        break;
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
  Map<String, dynamic> getSummaryData() {
    return {
      'knownCount': _sessionKnownWords.length,
      'unknownCount': _sessionUnknownWords.length,
      'reviewCount': _sessionReviewWords.length,
      'totalCount': _totalCount,
      'sessionUnknownWords': _sessionUnknownWords.toList(),
    };
  }

  /// เคลียร์ข้อมูลเซสชัน
  void clearSession() {
    _sessionKnownWords.clear();
    _sessionUnknownWords.clear();
    _sessionReviewWords.clear();
  }

  void dispose() {
    flutterTts.stop();
  }
}
