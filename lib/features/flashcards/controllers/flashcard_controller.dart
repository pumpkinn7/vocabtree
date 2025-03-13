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
  }) {
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

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
    try {
      final mainWord = flashcard.mainWord;

      // ลบคำออกจาก set อื่นๆ ก่อน
      _sessionKnownWords.remove(mainWord);
      _sessionUnknownWords.remove(mainWord);
      _sessionReviewWords.remove(mainWord);

      // เพิ่มลง set ตามทิศทางที่ปัด
      switch (direction) {
        case SwipeDirection.right:
          _sessionKnownWords.add(mainWord);
          await Future.wait([
            repository.saveUserFlashcardStatus(
                userId, topic, flashcard, true, false),
            service.saveWordStatus(userId, topic, flashcard.id, direction),
          ]);
          break;
        case SwipeDirection.left:
          _sessionUnknownWords.add(mainWord);
          await Future.wait([
            repository.saveUserFlashcardStatus(
                userId, topic, flashcard, false, false),
            service.saveWordStatus(userId, topic, flashcard.id, direction),
          ]);
          break;
        case SwipeDirection.up:
          _sessionReviewWords.add(mainWord);
          await Future.wait([
            repository.saveUserFlashcardStatus(
                userId, topic, flashcard, false, true),
            service.saveWordStatus(userId, topic, flashcard.id, direction),
          ]);
          break;
      }

      AppLogger.i(
          _tag, 'บันทึกสถานะการ์ด ${flashcard.mainWord} สำเร็จ: $direction');
    } catch (e) {
      AppLogger.e(
          _tag, 'เกิดข้อผิดพลาดในการบันทึกสถานะการ์ด ${flashcard.mainWord}', e);
    }
  }

  /// อ่านออกเสียงคำศัพท์
  Future<void> speakWord(String text) async {
    await flutterTts.speak(text);
  }

  /// ดึงภาพพื้นหลังตามระดับ CEFR
  String getBackgroundImageByLevel() {
    // ตรวจสอบหัวข้อที่ขึ้นต้นด้วย CEFR level
    if (topic.startsWith('B1_')) {
      return 'assets/images/spring.png';
    } else if (topic.startsWith('B2_')) {
      return 'assets/images/summer.png';
    } else if (topic.startsWith('C1_')) {
      return 'assets/images/autumn.png';
    } else if (topic.startsWith('C2_')) {
      return 'assets/images/winter.png';
    }

    // ถ้าไม่ได้เริ่มต้นด้วย CEFR prefix ให้ดูจาก 2 ตัวแรก
    if (topic.length >= 2) {
      String prefix = topic.substring(0, 2).toUpperCase();

      switch (prefix) {
        case 'B1':
          return 'assets/images/spring.png';
        case 'B2':
          return 'assets/images/summer.png';
        case 'C1':
          return 'assets/images/autumn.png';
        case 'C2':
          return 'assets/images/winter.png';
      }
    }

    // กรณีไม่พบรูปแบบใดๆ
    return 'assets/images/spring.png';
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
}
