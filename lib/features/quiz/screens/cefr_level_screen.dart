import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timelines/timelines.dart';

import '../../flashcards/screens/flashcard_topic_screen.dart';
import '../../quiz/screens/quiz_topic_screen.dart';

class CefrLevelScreen extends StatefulWidget {
  final String cefrLevel;

  const CefrLevelScreen({super.key, required this.cefrLevel});

  @override
  State<CefrLevelScreen> createState() => _CefrLevelScreenState();
}

class _CefrLevelScreenState extends State<CefrLevelScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<Map<String, dynamic>> _fetchAllData() async {
    final userId = user?.uid ?? '';

    // 1) ดึงรายชื่อ topics ของ CEFR นี้
    final cefrDoc = await FirebaseFirestore.instance
        .collection('cefr_levels')
        .doc(widget.cefrLevel)
        .get();
    final cefrData = cefrDoc.data() ?? {};
    final topicsMap = (cefrData['topics'] ?? {}) as Map<String, dynamic>;
    // เรียงชื่อ topic ให้เป็นลำดับที่ต้องการ
    final topics = topicsMap.keys.toList()..sort();

    // 2) ดึงคะแนนสูงสุดของแต่ละ topic จาก quizHistory
    Map<String, double> topicMaxScores = {};
    if (userId.isNotEmpty) {
      final historySnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('quizHistory')
          .get();

      for (var doc in historySnap.docs) {
        final data = doc.data();
        final level = data['cefrLevel'] as String? ?? '';
        final topic = data['topic'] as String? ?? '';
        final percentage = (data['percentage'] as num?)?.toDouble() ?? 0.0;

        // เช็คว่า quizHistory นี้ตรงกับ CEFR ปัจจุบันไหม
        if (level == widget.cefrLevel && topic.isNotEmpty) {
          // เก็บค่า percentage สูงสุดของ topic นั้น ๆ
          if (!topicMaxScores.containsKey(topic) ||
              topicMaxScores[topic]! < percentage) {
            topicMaxScores[topic] = percentage;
          }
        }
      }
    }

    // 3) ดึงชื่อรูปภาพ (รางวัล) ของแต่ละ topic (ถ้ามี)
    final rewardsSnap =
    await FirebaseFirestore.instance.collection('topic_rewards').get();
    Map<String, String> topicImages = {};
    for (var doc in rewardsSnap.docs) {
      final t = doc.id;
      final imageName = doc.data()['imageName'] as String? ?? '';
      if (imageName.isNotEmpty) {
        topicImages[t] = 'assets/images/$imageName.png';
      }
    }

    return {
      'topics': topics,                // List<String>
      'topicMaxScores': topicMaxScores, // Map<String, double>
      'topicImages': topicImages,      // Map<String, String>
    };
  }

  /// ฟังก์ชันใหม่: เช็คว่าหัวข้อนี้ถูกปลดล็อคหรือยัง
  /// - ถ้าเป็น topic แรก (index == 0) และชื่อว่า daily_life => ปลดล็อคเสมอ
  /// - ถ้าไม่ใช่หัวข้อแรก => ต้องดูว่าหัวข้อก่อนหน้าผ่าน >= 60 หรือไม่
  bool _isUnlocked({
    required String topic,
    required List<String> sortedTopics,
    required int index,
    required Map<String, double> topicMaxScores,
  }) {
    // ถ้าเป็นหัวข้อแรก และเรากำหนดให้ daily_life ปลดล็อคเสมอ
    if (index == 0 && topic == 'daily_life') {
      return true;
    }

    // ถ้าเป็นหัวข้อแรก (index == 0) แต่ไม่ใช่ daily_life ก็อาจจะล็อค/ปลดล็อคตาม logic อื่น
    if (index == 0) {
      // ถ้าต้องการปลดล็อคตลอด ไม่ว่า topic อะไร
      return true;
    }

    // ไม่ใช่หัวข้อแรก => ต้องผ่านหัวข้อก่อนหน้า >= 60
    final prevTopic = sortedTopics[index - 1];
    final prevScore = topicMaxScores[prevTopic] ?? 0.0;
    // ถ้าหัวข้อก่อนหน้า (prevTopic) >= 60 => ปลดล็อค
    return prevScore >= 60.0;
  }

  String _formatTopicName(String key, int index) {
    return '${index + 1}. '
        '${key.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ')}';
  }

  @override
  Widget build(BuildContext context) {
    // ป้องกันการ pop ออกจาก CEFR Screen แล้วกลับไปหน้าไหนสักหน้า
    // (แล้วแต่ความต้องการ ถ้าไม่ต้องการ block กลับ ก็ลบ WillPopScope ออก)
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('คำศัพท์ภาษาอังกฤษระดับ ${widget.cefrLevel}'),
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _fetchAllData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading data.'));
            }

            final data = snapshot.data ?? {};
            final topics = data['topics'] as List<String>? ?? [];
            final topicMaxScores =
                data['topicMaxScores'] as Map<String, double>? ?? {};
            final topicImages = data['topicImages'] as Map<String, String>? ?? {};

            if (topics.isEmpty) {
              return const Center(child: Text('No topics available.'));
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Timeline.tileBuilder(
                theme: TimelineThemeData(
                  nodePosition: 0.1,
                  connectorTheme: const ConnectorThemeData(
                    thickness: 2.0,
                  ),
                ),
                builder: TimelineTileBuilder.connected(
                  connectionDirection: ConnectionDirection.before,
                  itemCount: topics.length,
                  contentsBuilder: (context, index) {
                    final topicKey = topics[index];

                    // ใช้ฟังก์ชัน _isUnlocked แบบใหม่
                    final unlocked = _isUnlocked(
                      topic: topicKey,
                      sortedTopics: topics,
                      index: index,
                      topicMaxScores: topicMaxScores,
                    );

                    final imagePath = topicImages[topicKey];

                    return Opacity(
                      opacity: unlocked ? 1.0 : 0.5,
                      child: Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 8.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  spreadRadius: 2,
                                  offset: Offset(0, 2),
                                )
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // ด้านซ้ายเป็นชื่อหัวข้อ + ปุ่ม flashcard/quiz
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _formatTopicName(topicKey, index),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            TextButton(
                                              onPressed: unlocked
                                                  ? () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        FlashcardScreen(
                                                          topic: topicKey,
                                                          userId:
                                                          user?.uid ?? '',
                                                        ),
                                                  ),
                                                ).then((_) {
                                                  // กลับมาแล้วรีเฟรช
                                                  setState(() {});
                                                });
                                              }
                                                  : null,
                                              child: const Text('Flashcard'),
                                            ),
                                            const SizedBox(width: 8),
                                            TextButton(
                                              onPressed: unlocked
                                                  ? () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        QuizTopicScreen(
                                                          topic: topicKey,
                                                        ),
                                                  ),
                                                ).then((_) {
                                                  // กลับมาแล้วรีเฟรช
                                                  setState(() {});
                                                });
                                              }
                                                  : null,
                                              child: const Text('Quiz'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // ด้านขวาถ้ามีภาพ reward
                                  if (imagePath != null)
                                    Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(8.0),
                                          child: Image.asset(
                                            imagePath,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text('การปลดล็อค'),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                          // ถ้า locked ใส่ไอคอนกุญแจ
                          if (!unlocked)
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.lock,
                                  size: 50,
                                  color: Colors.grey.withOpacity(0.8),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                  // จุด indicator
                  indicatorBuilder: (context, index) {
                    final topicKey = topics[index];
                    final unlocked = _isUnlocked(
                      topic: topicKey,
                      sortedTopics: topics,
                      index: index,
                      topicMaxScores: topicMaxScores,
                    );
                    return DotIndicator(
                      color: unlocked ? Colors.green : Colors.grey,
                      size: 20.0,
                    );
                  },
                  // เส้นเชื่อมต่อระหว่างหัวข้อ
                  connectorBuilder: (context, index, type) {
                    final topicKey = topics[index];
                    final unlocked = _isUnlocked(
                      topic: topicKey,
                      sortedTopics: topics,
                      index: index,
                      topicMaxScores: topicMaxScores,
                    );
                    return SolidLineConnector(
                      color: unlocked ? Colors.green : Colors.grey,
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
