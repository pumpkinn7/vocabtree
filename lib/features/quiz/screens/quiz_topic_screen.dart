// quiz_topic_screen.dart
// ignore_for_file: depend_on_referenced_packages, no_leading_underscores_for_local_identifiers, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class QuizTopicScreen extends StatefulWidget {
  final String topic; // รับหัวข้อเป็นพารามิเตอร์

  const QuizTopicScreen({super.key, required this.topic});

  @override
  _QuizTopicScreenState createState() => _QuizTopicScreenState();
}

class _QuizTopicScreenState extends State<QuizTopicScreen> {
  final FlutterTts flutterTts = FlutterTts();
  List<DocumentSnapshot> quizzes = [];
  int currentIndex = 0;
  int correctAnswers = 0;

  @override
  void initState() {
    super.initState();
    _fetchQuizzes();
  }

  Future<void> _fetchQuizzes() async {
    // ดึงควิซทั้งหมด
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('quizzes').get();
    setState(() {
      quizzes = snapshot.docs;
    });
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  Future<void> _checkAnswer(bool isCorrect, String correctAnswer) async {
    if (isCorrect) {
      correctAnswers++;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ตอบถูกต้อง!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ตอบผิด! คำตอบที่ถูกคือ $correctAnswer'),
          backgroundColor: Colors.red,
        ),
      );
    }

    await Future.delayed(const Duration(seconds: 2)); // รอ 2 วินาทีก่อนเปลี่ยนคำถาม

    setState(() {
      if (currentIndex < quizzes.length - 1) {
        currentIndex++;
      } else {
        // เมื่อทำควิซเสร็จสิ้น แสดงหน้าผลลัพธ์
        _showResultDialog();
      }
    });
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ผลลัพธ์การทำควิซ'),
          content: Text('คุณตอบถูก $correctAnswers จาก ${quizzes.length} ข้อ'),
          actions: <Widget>[
            TextButton(
              child: const Text('ปิด'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // กลับไปยังหน้าหลัก
              },
            ),
            TextButton(
              child: const Text('เริ่มใหม่'),
              onPressed: () {
                setState(() {
                  currentIndex = 0;
                  correctAnswers = 0;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (quizzes.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Quiz - ${widget.topic.replaceAll('_', ' ').toUpperCase()}'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    DocumentSnapshot currentQuiz = quizzes[currentIndex];
    String question = currentQuiz['question'];
    List<dynamic> options = currentQuiz['options'];
    String correctAnswer = options.firstWhere((option) => option['isCorrect'])['option'];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  'Quiz - ${widget.topic.replaceAll('_', ' ').toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'ฉันต้องทำอะไร? : ฟังเสียงและเลือกศัพท์ที่ถูกต้อง',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (currentIndex + 1) / quizzes.length,
              backgroundColor: Colors.grey[300],
              color: Colors.orange,
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              'ข้อที่ ${currentIndex + 1} of ${quizzes.length}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.volume_up,
                          size: 50, color: Colors.orange),
                      onPressed: () {
                        _speak(question);
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'กดเพื่อฟังเสียง',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Text(
                  question,
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ...options.map<Widget>((option) {
              return _buildAnswerButton(context, option['option'],
                  option['isCorrect'], correctAnswer);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerButton(
      BuildContext context, String text, bool isCorrect, String correctAnswer) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            _checkAnswer(isCorrect, correctAnswer);
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.white,
            side: const BorderSide(color: Colors.grey),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 18, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
