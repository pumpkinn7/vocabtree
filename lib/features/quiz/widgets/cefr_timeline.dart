import 'package:flutter/material.dart';
import '../models/topic_model.dart';
import 'cefr_topic_card.dart';

class CefrTimeline extends StatelessWidget {
  final List<TopicModel> topics;
  final Function(String) onFlashcardTap;
  final Function(String) onQuizTap;

  const CefrTimeline({
    super.key,
    required this.topics,
    required this.onFlashcardTap,
    required this.onQuizTap,
  });

  @override
  Widget build(BuildContext context) {
    // แยกหัวข้อเป็นชุด (ละ 3-5 หัวข้อตามความยาวของลิสต์) เพื่อแสดงผลเป็นกลุ่ม
    final chunkSize = topics.length <= 6 ? 3 : 5;
    final topicChunks = _chunkList(topics, chunkSize);

    return Column(
      children: [
        // แสดงแต่ละกลุ่มหัวข้อ
        for (int chunkIndex = 0; chunkIndex < topicChunks.length; chunkIndex++)
          _buildTopicGroup(context, topicChunks[chunkIndex], chunkIndex),
      ],
    );
  }

  // สร้างกลุ่มหัวข้อ
  Widget _buildTopicGroup(
      BuildContext context, List<TopicModel> topicGroup, int groupIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (TopicModel topic in topicGroup)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // เปลี่ยนเป็น center
              children: [
                // แสดงเฉพาะจุดสถานะ
                SizedBox(
                  width: 40,
                  child: Container(
                    width: 16, // ลดขนาดจุดลง
                    height: 16, // ลดขนาดจุดลง
                    decoration: BoxDecoration(
                      color: topic.statusColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),

                // เนื้อหาของหัวข้อ
                Expanded(
                  child: CefrTopicCard(
                    topic: topic,
                    onFlashcardTap: () => onFlashcardTap(topic.id),
                    onQuizTap: () => onQuizTap(topic.id),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Helper function สำหรับแบ่ง List เป็นกลุ่มย่อย
  List<List<TopicModel>> _chunkList(List<TopicModel> list, int chunkSize) {
    List<List<TopicModel>> chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(
          i, i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }
}
