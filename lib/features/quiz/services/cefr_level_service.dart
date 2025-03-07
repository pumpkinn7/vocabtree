import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/topic_model.dart';
import '../services/firebase_service.dart';

class CefrLevelService {
  // ดึงข้อมูลการปลดล็อกหัวข้อและรูปภาพรางวัล
  static Future<Map<String, dynamic>> fetchCefrLevelData(String userId) async {
    // ดึงสถานะการปลดล็อกหัวข้อจาก Firestore
    Map<String, dynamic> unlockedTopics = {};
    if (userId.isNotEmpty) {
      final progressDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('progress')
          .doc('unlockedTopics')
          .get();
      unlockedTopics = progressDoc.data() ?? {};
    }

    // ดึงชื่อรูปภาพรางวัลของแต่ละ topic
    final rewardsSnap =
        await FirebaseFirestore.instance.collection('topic_rewards').get();
    Map<String, String> topicImages = {};
    for (var doc in rewardsSnap.docs) {
      final topicId = doc.id;
      final imageName = doc.data()['imageName'] as String? ?? '';
      if (imageName.isNotEmpty) {
        topicImages[topicId] = 'assets/images/$imageName.png';
      }
    }

    return {
      'unlockedTopics': unlockedTopics,
      'topicImages': topicImages,
    };
  }

  // แปลงข้อมูลเป็น TopicModel
  static List<TopicModel> getTopicModels(
    String cefrLevel,
    Map<String, dynamic> unlockedTopics,
    Map<String, String> topicImages,
  ) {
    final topics = FirebaseService.cefrTopics[cefrLevel] ?? [];

    return List.generate(
      topics.length,
      (index) {
        final topicId = topics[index];
        final levelTopics =
            unlockedTopics[cefrLevel] as Map<String, dynamic>? ?? {};
        final isUnlocked = levelTopics[topicId] == true;

        return TopicModel(
          id: topicId,
          title: topicId,
          index: index,
          isUnlocked: isUnlocked,
          imagePath: topicImages[topicId],
          cefrLevel: cefrLevel,
        );
      },
    );
  }

  // ฟังก์ชันสำหรับแสดงชื่อระดับ CEFR
  static String getSeasonTitle(String cefrLevel) {
    switch (cefrLevel) {
      case 'B1':
        return 'Spring ระดับพื้นฐานถึงปานกลาง';
      case 'B2':
        return 'Summer ระดับปานกลาง';
      case 'C1':
        return 'Autumn ระดับกลางค่อนข้างสูง';
      case 'C2':
        return 'Winter ระดับสูง';
      default:
        return 'หมวดคำศัพท์ภาษาอังกฤษ';
    }
  }
}
