import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';
import 'package:vocabtree/features/quiz/models/daily_vocabulary.dart';
import '../models/vocabulary_item_model.dart';

class VocabularyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger('VocabularyService');

  Future<DailyVocabulary?> getRandomVocabulary() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection('words').limit(100).get();

      if (snapshot.docs.isEmpty) {
        _logger.warning('ไม่พบข้อมูลคำศัพท์ใน words collection');
        return null;
      }

      // สุ่มเลือกหนึ่งเอกสาร
      final int randomIndex =
          DateTime.now().millisecondsSinceEpoch % snapshot.docs.length;
      final DocumentSnapshot document = snapshot.docs[randomIndex];

      if (!document.exists) {
        return null;
      }

      final data = document.data() as Map<String, dynamic>;
      final String word = data['mainWord'] ?? '';
      String type = data['mainPos'] ?? '';
      String cefrLevel = '';

      // ตรวจสอบว่ามีข้อมูล part of speech หรือไม่
      if (type.isEmpty) {
        if (data['senses'] is List && (data['senses'] as List).isNotEmpty) {
          final firstSense = (data['senses'] as List)[0];
          if (firstSense is Map && firstSense.containsKey('partOfSpeech')) {
            type = firstSense['partOfSpeech'] ?? '';
          }
          if (firstSense is Map && firstSense.containsKey('cefr')) {
            cefrLevel = firstSense['cefr'] ?? '';
          }
        }
      }

      return DailyVocabulary(
        word: word,
        type: type,
        cefrLevel: cefrLevel,
      );
    } catch (e) {
      _logger.severe('เกิดข้อผิดพลาดในการดึงคำศัพท์แบบสุ่ม', e);
      return null;
    }
  }

  List<VocabularyItemModel> getVocabularyCategories() {
    return [
      VocabularyItemModel(
        title: 'SPRING',
        level: 'Basic & Intermediate',
        difficulty: 'ระดับพื้นฐานถึงปานกลาง',
        imagePath: 'assets/images/oak_6977599.png',
        cefrLevel: 'B1',
      ),
      VocabularyItemModel(
        title: 'SUMMER',
        level: 'Intermediate',
        difficulty: 'ระดับปานกลาง',
        imagePath: 'assets/images/tree_6977578.png',
        cefrLevel: 'B2',
      ),
      VocabularyItemModel(
        title: 'AUTUMN',
        level: 'Upper Intermediate',
        difficulty: 'ระดับกลางค่อนข้างสูง',
        imagePath: 'assets/images/tree_6977585.png',
        cefrLevel: 'C1',
      ),
      VocabularyItemModel(
        title: 'WINTER',
        level: 'Advanced',
        difficulty: 'ระดับสูง',
        imagePath: 'assets/images/tree_6977597.png',
        cefrLevel: 'C2',
      ),
    ];
  }
}
