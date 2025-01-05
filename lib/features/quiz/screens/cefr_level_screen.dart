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

    // ดึงรายชื่อ topics
    final cefrDoc = await FirebaseFirestore.instance
        .collection('cefr_levels')
        .doc(widget.cefrLevel)
        .get();
    final cefrData = cefrDoc.data() ?? {};
    final topicsMap = (cefrData['topics'] ?? {}) as Map<String, dynamic>;
    final topics = topicsMap.keys.toList()..sort();

    // ดึงคะแนนสูงสุดของแต่ละ topic
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

        if (level == widget.cefrLevel && topic.isNotEmpty) {
          if (!topicMaxScores.containsKey(topic) ||
              topicMaxScores[topic]! < percentage) {
            topicMaxScores[topic] = percentage;
          }
        }
      }
    }

    // ดึงรูปภาพต้นไม้
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
      'topics': topics,
      'topicMaxScores': topicMaxScores,
      'topicImages': topicImages,
    };
  }

  bool _isUnlocked(String topic, Map<String, double> topicMaxScores) {
    final score = topicMaxScores[topic] ?? 0.0;
    return score >= 60.0;
  }

  String _formatTopicName(String key, int index) {
    return '${index + 1}. '
        '${key.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ')}';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // ป้องกันการย้อนกลับไปยังหน้าหลัก
        Navigator.pop(context); // หรือจัดการกลับไปยังหน้าที่ต้องการ
        return false; // ป้องกันการย้อนกลับเริ่มต้น
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
                    final unlocked = _isUnlocked(topicKey, topicMaxScores);
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
                                                );
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
                                                );
                                              }
                                                  : null,
                                              child: const Text('Quiz'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
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
                  indicatorBuilder: (context, index) {
                    final topicKey = topics[index];
                    final unlocked = _isUnlocked(topicKey, topicMaxScores);
                    return DotIndicator(
                      color: unlocked ? Colors.green : Colors.grey,
                      size: 20.0,
                    );
                  },
                  connectorBuilder: (context, index, type) {
                    final topicKey = topics[index];
                    final unlocked = _isUnlocked(topicKey, topicMaxScores);
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
