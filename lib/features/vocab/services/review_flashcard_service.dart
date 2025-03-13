import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';

/// Service สำหรับจัดการคำศัพท์ที่ต้องการทบทวน
class ReviewFlashcardService {
  final FlutterTts flutterTts = FlutterTts();
  final GoogleTranslator translator = GoogleTranslator();

  ReviewFlashcardService() {
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  /// ลบคำออกจาก review_words array
  Future<void> removeFromReview(
      String userId, String topic, String word) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('vocabulary_progress')
          .doc(topic)
          .update({
        'review_words': FieldValue.arrayRemove([word])
      });
    } catch (_) {
      // ไม่ต้องแสดง error
    }
  }

  /// สั่ง TTS อ่านคำศัพท์
  Future<void> speakWord(String text) async {
    await flutterTts.speak(text);
  }

  /// แปลคำศัพท์
  Future<String> translateWord(String text) async {
    final translation = await translator.translate(
      text,
      from: 'en',
      to: 'th',
    );

    return translation.text;
  }

  /// ดึงภาพพื้นหลังตามระดับ CEFR
  String getBackgroundImageByLevel(String level) {
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
}
