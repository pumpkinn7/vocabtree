import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timelines/timelines.dart';

import '../../flashcards/screens/flashcard_topic_screen.dart';
import '../../quiz/screens/quiz_topic_screen.dart';
import '../services/firebase_service.dart';

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

    // ดึงชื่อรูปภาพ (รางวัล) ของแต่ละ topic (ถ้ามี)
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
      'unlockedTopics': unlockedTopics,
      'topicImages': topicImages,
    };
  }

  /// ฟังก์ชันตรวจสอบว่าหัวข้อถูกปลดล็อกหรือไม่
  bool _isUnlocked({
    required String topic,
    required String cefrLevel,
    required Map<String, dynamic> unlockedTopics,
  }) {
    final levelTopics = unlockedTopics[cefrLevel] as Map<String, dynamic>? ?? {};
    return levelTopics[topic] == true;
  }

  String _formatTopicName(String key, int index) {
    return '${index + 1}. '
        '${key.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          final unlockedTopics = data['unlockedTopics'] as Map<String, dynamic>? ?? {};
          final topicImages = data['topicImages'] as Map<String, String>? ?? {};
          final topics = FirebaseService.cefrTopics[widget.cefrLevel] ?? [];

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
                  final unlocked = _isUnlocked(
                    topic: topicKey,
                    cefrLevel: widget.cefrLevel,
                    unlockedTopics: unlockedTopics,
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                                        userId: user?.uid ?? '',
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
                                                  builder: (context) => QuizTopicScreen(
                                                    topic: topicKey,
                                                    cefrLevel: widget.cefrLevel,
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
                                        borderRadius: BorderRadius.circular(8.0),
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
                    cefrLevel: widget.cefrLevel,
                    unlockedTopics: unlockedTopics,
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
                    cefrLevel: widget.cefrLevel,
                    unlockedTopics: unlockedTopics,
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
    );
  }
}
