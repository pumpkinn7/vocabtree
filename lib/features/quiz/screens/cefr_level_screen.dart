import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  final levelsOrder = ['B1', 'B2', 'C1', 'C2'];

  Future<Map<String, dynamic>> _fetchAllLevelsData() async {
    final userId = user?.uid;
    Map<String, List<String>> allLevelsTopics = {};

    for (var level in levelsOrder) {
      final cefrDoc = await FirebaseFirestore.instance
          .collection('cefr_levels')
          .doc(level)
          .get();
      final data = cefrDoc.data() ?? {};
      final topicsMap = (data['topics'] ?? {}) as Map<String, dynamic>;
      final topics = topicsMap.keys.toList()..sort();
      allLevelsTopics[level] = topics;
    }

    Map<String, Map<String, double>> userTopicScores = {};
    if (userId != null) {
      final historySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('quizHistory')
          .get();

      for (var doc in historySnapshot.docs) {
        final histData = doc.data();
        final level = histData['cefrLevel'] as String?;
        final topic = histData['topic'] as String?;
        final percentage = ((histData['percentage'] ?? 0) as num).toDouble();
        if (level != null && topic != null) {
          userTopicScores.putIfAbsent(level, () => {});
          userTopicScores[level]![topic] = userTopicScores[level]![topic] == null
              ? percentage
              : (userTopicScores[level]![topic]! > percentage
              ? userTopicScores[level]![topic]!
              : percentage);
        }
      }
    }

    return {
      'allLevelsTopics': allLevelsTopics,
      'userTopicScores': userTopicScores,
    };
  }

  bool _isTopicUnlockedWithLevelsOrder(
      List<String> currentLevelTopics,
      int index,
      Map<String, List<String>> allLevelsTopics,
      Map<String, Map<String, double>> userTopicScores,
      ) {
    final currentLevel = widget.cefrLevel;
    final currentLevelIndex = levelsOrder.indexOf(currentLevel);

    if (currentLevelIndex == -1) {
      // ถ้าไม่พบ level ในลิสต์ ให้ปลดล็อคไปก่อน
      return true;
    }

    if (currentLevelIndex == 0) {
      // ระดับแรก (B1)
      if (index == 0) {
        return true;
      } else {
        final prevTopic = currentLevelTopics[index - 1];
        final prevScore = userTopicScores[currentLevel]?[prevTopic] ?? -1;
        return prevScore >= 60.0;
      }
    } else {
      // ระดับ B2, C1, C2
      if (index == 0) {
        // topic แรกของระดับปัจจุบัน ต้องตรวจระดับก่อนหน้า
        final previousLevel = levelsOrder[currentLevelIndex - 1];
        final previousLevelTopics = allLevelsTopics[previousLevel] ?? [];
        if (previousLevelTopics.isEmpty) {
          return true;
        }
        final lastTopicPrevLevel = previousLevelTopics.last;
        final lastTopicScore = userTopicScores[previousLevel]?[lastTopicPrevLevel] ?? -1;
        return lastTopicScore >= 60.0;
      } else {
        final prevTopic = currentLevelTopics[index - 1];
        final prevScore = userTopicScores[currentLevel]?[prevTopic] ?? -1;
        return prevScore >= 60.0;
      }
    }
  }

  String _formatTopicName(String topicKey) {
    return topicKey
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Widget _buildProgressItem(
      BuildContext context, {
        required String title,
        VoidCallback? onFlashcardPressed,
        VoidCallback? onQuizPressed,
        required bool isUnlocked,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
          color: isUnlocked ? Colors.white : Colors.grey[200],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (!isUnlocked)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Topic นี้ถูกล็อคอยู่! คุณต้องทำ Topic ก่อนหน้าให้ได้อย่างน้อย 60% เพื่อปลดล็อค (รวมถึงการผ่านระดับก่อนหน้าด้วย)',
                  style: TextStyle(color: Colors.red[800], fontSize: 14),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: isUnlocked ? onFlashcardPressed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isUnlocked ? Colors.orange : Colors.grey,
                  ),
                  child: const Text('Flashcard'),
                ),
                ElevatedButton(
                  onPressed: isUnlocked ? onQuizPressed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isUnlocked ? Colors.blue : Colors.grey,
                  ),
                  child: const Text('Quiz'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton( // เปลี่ยนจาก pushReplacement เป็น pop
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // กลับไปยังหน้าเดิมที่มี bottom_navbar
          },
        ),
        title: Text(
          'คำศัพท์ภาษาอังกฤษระดับ ${widget.cefrLevel}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _fetchAllLevelsData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Error loading topics'));
            }

            final data = snapshot.data ?? {};
            final allLevelsTopics = data['allLevelsTopics'] as Map<String, List<String>>? ?? {};
            final userTopicScores = data['userTopicScores'] as Map<String, Map<String, double>>? ?? {};
            final topics = allLevelsTopics[widget.cefrLevel] ?? [];

            if (topics.isEmpty) {
              return const Center(child: Text('No topics available.'));
            }

            return ListView.builder(
              itemCount: topics.length,
              itemBuilder: (context, index) {
                final topicKey = topics[index];
                final isUnlocked = _isTopicUnlockedWithLevelsOrder(topics, index, allLevelsTopics, userTopicScores);

                return _buildProgressItem(
                  context,
                  title: '${index + 1}. ${_formatTopicName(topicKey)}',
                  onFlashcardPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FlashcardScreen(
                          topic: topicKey,
                          userId: user?.uid ?? '',
                        ),
                      ),
                    );
                  },
                  onQuizPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizTopicScreen(topic: topicKey),
                      ),
                    );
                  },
                  isUnlocked: isUnlocked,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
