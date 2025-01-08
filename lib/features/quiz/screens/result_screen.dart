import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'cefr_level_screen.dart';
import '../services/firebase_service.dart'; // เพิ่ม import FirebaseService
import '../../quiz/screens/quiz_topic_screen.dart'; // เพิ่ม import QuizTopicScreen

class ResultScreen extends StatefulWidget {
  final String cefrLevel;
  final String topic;
  final int score;
  final int totalQuestions;
  final double percentage;
  final int? timeTaken;

  const ResultScreen({
    super.key,
    required this.cefrLevel,
    required this.topic,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    this.timeTaken,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _saveQuizResult();
    _checkUnlockNextTopic();
  }

  Future<void> _saveQuizResult() async {
    if (user == null) return;
    final userId = user!.uid;

    final quizData = {
      'cefrLevel': widget.cefrLevel,
      'topic': widget.topic,
      'score': widget.score,
      'totalQuestions': widget.totalQuestions,
      'percentage': widget.percentage,
      'timeTaken': widget.timeTaken ?? 0,
      'doneAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('quizHistory')
        .add(quizData);

    // ดึงชื่อรูปภาพรางวัลของหัวข้อนี้
    String rewardImageName = await _getRewardImageName(widget.topic);

    // หากคะแนนผ่าน ≥ 60% ให้ปลดล็อคหัวข้อถัดไปและอัปเดต progress
    if (widget.percentage >= 60.0) {
      await FirebaseService.updateUserProgress(
        userId,
        widget.topic,
        rewardImageName,
        widget.cefrLevel,
      );
    }
  }

  Future<String> _getRewardImageName(String topic) async {
    // ดึงข้อมูล imageName จาก topic_rewards
    final doc = await FirebaseFirestore.instance
        .collection('topic_rewards')
        .doc(topic)
        .get();
    if (doc.exists) {
      final data = doc.data();
      return data?['imageName'] as String? ?? "";
    }
    return "";
  }

  Future<void> _checkUnlockNextTopic() async {
    // หาก percentage >= 60% แสดงว่าปลดล็อคหัวข้อถัดไป
    if (widget.percentage >= 60.0) {
      setState(() {
        // ใช้สำหรับ UI แต่การปลดล็อคจริงถูกจัดการใน _saveQuizResult()
      });
    }
  }

  // ฟังก์ชันใหม่เพื่อหาหัวข้อถัดไป
  Future<String?> _getNextTopic() async {
    final cefrDoc = await FirebaseFirestore.instance
        .collection('cefr_levels')
        .doc(widget.cefrLevel)
        .get();
    final data = cefrDoc.data() ?? {};
    final topicsMap = (data['topics'] ?? {}) as Map<String, dynamic>;
    final topics = topicsMap.keys.toList()..sort(); // จัดเรียงหัวข้อตามลำดับที่ต้องการ

    final currentIndex = topics.indexOf(widget.topic);
    if (currentIndex == -1 || currentIndex + 1 >= topics.length) {
      return null; // ไม่มีหัวข้อถัดไป
    }
    return topics[currentIndex + 1];
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = widget.percentage >= 60.0;

    return Scaffold(
      // ลบ AppBar back button ออก
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('ผลการทำ Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Level: ${widget.cefrLevel}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Topic: ${_formatTopicName(widget.topic)}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              'คะแนน: ${widget.score}/${widget.totalQuestions}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'เปอร์เซ็นต์: ${widget.percentage.toStringAsFixed(2)}%',
              style: const TextStyle(fontSize: 18),
            ),
            if (widget.timeTaken != null)
              Text(
                'เวลาที่ใช้: ${_formatTime(widget.timeTaken!)}',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 16),
            if (unlocked)
              Text(
                'ยินดีด้วย! คุณทำได้ >= 60% หัวข้อถัดไปปลดล็อคแล้ว!',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.green[800],
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              )
            else
              Text(
                'คุณได้ไม่ถึง 60% หัวข้อต่อไปยังไม่ปลดล็อค\nลองใหม่อีกครั้ง!',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.red[800],
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // ปุ่ม ย้อนกลับ
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('ย้อนกลับ'),
                ),
                // ปุ่ม หัวข้อถัดไป
                ElevatedButton(
                  onPressed: unlocked
                      ? () async {
                    String? nextTopic = await _getNextTopic();
                    if (nextTopic != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizTopicScreen(
                            topic: nextTopic,
                            cefrLevel: widget.cefrLevel,
                          ),
                        ),
                      );
                    } else {
                      // ไม่มีหัวข้อถัดไป ไปยัง CefrLevelScreen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CefrLevelScreen(cefrLevel: widget.cefrLevel),
                        ),
                      );
                    }
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: unlocked ? Colors.green : Colors.grey,
                  ),
                  child: const Text('หัวข้อถัดไป'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTopicName(String topicKey) {
    return topicKey
        .split('_')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s นาที';
  }
}
