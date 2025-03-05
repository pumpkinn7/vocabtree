import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';
import 'package:vocabtree/features/quiz/models/daily_vocabulary.dart';

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

      // แปลงข้อมูลจาก document เป็น DailyVocabulary object
      return DailyVocabulary(
        word: data['word'] ?? data['name'] ?? '',
        type: data['type'] ?? data['part_of_speech'] ?? '',
        cefrLevel: data['cefrLevel'] ?? data['level'] ?? '',
      );
    } catch (e) {
      _logger.severe('Error getting random vocabulary: $e');
      return null;
    }
  }
}
