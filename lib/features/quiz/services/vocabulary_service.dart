import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';
import 'package:vocabtree/features/quiz/models/daily_vocabulary.dart';
import '../models/vocabulary_item_model.dart';

class VocabularyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger('VocabularyService');

  Future<DailyVocabulary?> getRandomVocabulary() async {
    try {
      // ดึงข้อมูลคำศัพท์จาก words collection โดยตรง
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
      final Map<String, dynamic> data = document.data() as Map<String, dynamic>;

      _logger.info('พบข้อมูลคำศัพท์: ${data.toString()}');

      String word = data['word'] ?? data['mainWord'] ?? '';
      String partOfSpeech = '';
      String definition = '';

      // ตรวจสอบ field partOfSpeech หรือ mainPos
      if (data['mainPos'] != null) {
        partOfSpeech = data['mainPos'];
      } else if (data['type'] != null) {
        partOfSpeech = data['type'];
      } else if (data['part_of_speech'] != null) {
        partOfSpeech = data['part_of_speech'];
      }

      // ตรวจสอบ field definition จาก senses ถ้ามี
      if (data['definition'] != null) {
        definition = data['definition'];
      } else if (data['senses'] is List &&
          (data['senses'] as List).isNotEmpty) {
        final firstSense = (data['senses'] as List).first;
        if (firstSense is Map<String, dynamic> &&
            firstSense['definition'] != null) {
          definition = firstSense['definition'];
        }
      }

      return DailyVocabulary(
        word: word,
        type: partOfSpeech,
        cefrLevel: data['cefrLevel'] ?? data['level'] ?? '',
        definition: definition,
        translation: data['translation'],
        example: data['example'],
      );
    } catch (e) {
      _logger.severe('Error getting random vocabulary: $e');
      return null;
    }
  }

  // ดึงรายการ vocabulary categories
  List<VocabularyItemModel> getVocabularyCategories() {
    return [
      VocabularyItemModel(
        title: 'SPRING',
        level: 'คำศัพท์ Basic & Intermediate',
        difficulty: 'ระดับพื้นฐานถึงปานกลาง',
        imagePath: 'assets/images/oak_6977599.png',
        cefrLevel: 'B1',
      ),
      VocabularyItemModel(
        title: 'SUMMER',
        level: 'คำศัพท์ Intermediate',
        difficulty: 'ระดับปานกลาง',
        imagePath: 'assets/images/tree_6977578.png',
        cefrLevel: 'B2',
      ),
      VocabularyItemModel(
        title: 'AUTUMN',
        level: 'คำศัพท์ Upper Intermediate',
        difficulty: 'ระดับกลางค่อนข้างสูง',
        imagePath: 'assets/images/tree_6977585.png',
        cefrLevel: 'C1',
      ),
      VocabularyItemModel(
        title: 'WINTER',
        level: 'คำศัพท์ Advanced',
        difficulty: 'ระดับสูง',
        imagePath: 'assets/images/tree_6977597.png',
        cefrLevel: 'C2',
      ),
    ];
  }
}
