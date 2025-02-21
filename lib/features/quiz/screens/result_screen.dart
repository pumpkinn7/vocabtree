import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vocabtree/features/quiz/services/firebase_service.dart';
import 'package:vocabtree/features/quiz/widgets/top_wrong_words.dart';

import '../../quiz/screens/quiz_topic_screen.dart';
import '../models/quiz_question_model.dart';
import '../models/quiz_result.dart';
import '../services/result_service.dart';
import '../widgets/cefr_chart.dart';
import '../widgets/score_progress.dart';

class ResultScreen extends StatefulWidget {
  final String cefrLevel;
  final String topic;
  final int score;
  final int totalQuestions;
  final double percentage;
  final Map<String, int> cefrDistribution;
  final List<QuizQuestionModel> wrongAnswers;

  const ResultScreen({
    super.key,
    required this.cefrLevel,
    required this.topic,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.cefrDistribution,
    required this.wrongAnswers,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> recentQuizzes = [];
  List<Map<String, dynamic>> topWrongWords = [];
  double? previousAverage;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (user == null) return;

    // บันทึกผลลัพธ์
    await ResultService.saveQuizResult(
      QuizResult(
        userId: user!.uid,
        topic: widget.topic,
        score: widget.score,
        totalQuestions: widget.totalQuestions,
        percentage: widget.percentage,
        wrongAnswers: widget.wrongAnswers.map((q) => q.mainWord).toList(),
      ),
    );

    // ดึงข้อมูลคำที่ตอบผิดบ่อย
    final wrongWords = await ResultService.getTopWrongWords(user!.uid);

    if (mounted) {
      setState(() {
        topWrongWords = wrongWords;
      });
    }
  }

  void _showAllWrongWords() {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('คำศัพท์ที่ตอบผิดทั้งหมด'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: FutureBuilder<List<Map<String, dynamic>>>(
            future: ResultService.getTopWrongWords(
              user?.uid ?? '',
              limit: 100, // หรือจำนวนที่ต้องการ
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final words = snapshot.data ?? [];
              return ListView.builder(
                itemCount: words.length,
                itemBuilder: (context, index) {
                  final word = words[index];
                  return ListTile(
                    title: Text(word['word']),
                    trailing: Text('ตอบผิด ${word['wrongCount']} ครั้ง'),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('ผลการทำแบบทดสอบ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'หมวดหมู่: ${_formatTopicName(widget.topic)}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),

            // 1. สัดส่วนระดับ CEFR
            const Text(
              'สัดส่วนระดับ CEFR',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            CefrChart(cefrDistribution: widget.cefrDistribution),
            const SizedBox(height: 24),

            // 2. คำศัพท์ที่ตอบผิดบ่อย
            if (topWrongWords.isNotEmpty) ...[
              TopWrongWords(
                wrongWords: topWrongWords,
                onViewAllPressed: _showAllWrongWords,
              ),
              const SizedBox(height: 24),
            ],

            // 3. Progress Bar สัดส่วนตอบถูก/ผิด
            ScoreProgress(percentage: widget.percentage),
            const SizedBox(height: 24),

            // 4. ปุ่มดำเนินการต่อ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('ย้อนกลับ'),
                ),
                ElevatedButton(
                  onPressed: widget.percentage >= 60.0 ? _goToNextTopic : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        widget.percentage >= 60.0 ? Colors.green : Colors.grey,
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

  Future<void> _goToNextTopic() async {
    final nextTopic = await _getNextTopic();
    if (nextTopic != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizTopicScreen(
            topic: nextTopic,
            cefrLevel: widget.cefrLevel,
          ),
        ),
      );
    }
  }

  Future<String?> _getNextTopic() async {
    final topics = FirebaseService.cefrTopics[widget.cefrLevel] ?? [];
    final currentIndex = topics.indexOf(widget.topic);
    if (currentIndex != -1 && currentIndex + 1 < topics.length) {
      return topics[currentIndex + 1];
    }
    return null;
  }

  String _formatTopicName(String topicKey) {
    return topicKey
        .split('_')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}
