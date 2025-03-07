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
    // สร้าง timeline แบบง่าย โดยใช้เพียง ListView แทนการใช้ timelines package
    return ListView.builder(
      itemCount: topics.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final topic = topics[index];
        return Column(
          children: [
            // เส้นเชื่อมต่อด้านบน (ยกเว้นรายการแรก)
            if (index > 0)
              Container(
                width: 2,
                height: 20,
                color: topics[index - 1].statusColor,
              ),

            // Indicator และ Content
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Indicator (จุดกลม)
                Column(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: topic.statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    // เส้นเชื่อมต่อด้านล่าง (ยกเว้นรายการสุดท้าย)
                    if (index < topics.length - 1)
                      Container(
                        width: 2,
                        height: 140, // ความสูงประมาณหนึ่งการ์ด
                        color: topic.statusColor,
                      ),
                  ],
                ),

                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: CefrTopicCard(
                    topic: topic,
                    onFlashcardTap: () => onFlashcardTap(topic.id),
                    onQuizTap: () => onQuizTap(topic.id),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
