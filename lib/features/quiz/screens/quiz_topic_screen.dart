import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/quiz_question_model.dart';
import '../services/firebase_service.dart';
import '../services/quiz_logic.dart';
import '../widgets/multiple_choice_widget.dart';
import '../widgets/drag_and_drop_widget.dart';
import '../widgets/matching_quiz_widget.dart';
import '../widgets/progress_bar.dart';
import 'result_screen.dart';

class QuizTopicScreen extends StatefulWidget {
  final String topic;

  const QuizTopicScreen({super.key, required this.topic});

  @override
  State<QuizTopicScreen> createState() => _QuizTopicScreenState();
}

class _QuizTopicScreenState extends State<QuizTopicScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  late Future<List<QuizQuestionModel>> _questionsFuture;

  // เก็บรายการคำถามหลังจากดึงและจัดเรียง
  List<QuizQuestionModel> _questions = [];

  int _currentQuestionIndex = 0;
  int _score = 0;

  // หากต้องการใช้ Timer
  bool useTimer = true;
  int totalTimeSeconds = 300; // เช่น 5 นาที สำหรับทั้ง Quiz
  Timer? _timer;
  int _timeLeft = 0;

  @override
  void initState() {
    super.initState();
    _questionsFuture = _loadQuestions();
    if (useTimer) {
      _timeLeft = totalTimeSeconds;
    }
  }

  Future<List<QuizQuestionModel>> _loadQuestions() async {
    // ดึงคำถามทุกประเภทจาก Firestore
    final cefrLevel = await FirebaseService.getCEFRLevelForTopic(widget.topic);
    // สมมุติว่ามีฟังก์ชันใน firebase_service: getQuestionsForTopic(cefrLevel, topic)
    final allQuestions = await FirebaseService.getQuestionsForTopic(cefrLevel, widget.topic);

    // ใช้ quiz_logic ในการเรียงและสุ่มคำถาม
    final arrangedQuestions = QuizLogic.arrangeAndShuffleQuestions(allQuestions);

    return arrangedQuestions;
  }

  void _startTimer() {
    if (!useTimer) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft <= 0) {
        timer.cancel();
        _submitQuiz();
      } else {
        setState(() {
          _timeLeft--;
        });
      }
    });
  }

  void _answerQuestion(bool correct) {
    if (correct) {
      _score++;
    }
    _goToNextQuestionOrFinish();
  }

  void _goToNextQuestionOrFinish() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      // ทำเสร็จ quiz แล้ว
      _submitQuiz();
    }
  }

  void _submitQuiz() {
    _timer?.cancel();
    final correctAnswers = _score;
    final totalQuestions = _questions.length;
    final percentage = (correctAnswers / totalQuestions) * 100;

    // ไปหน้า result_screen พร้อมส่งข้อมูล
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          cefrLevel: FirebaseService.getCEFRLevelForTopicSync(widget.topic),
          topic: widget.topic,
          score: correctAnswers,
          totalQuestions: totalQuestions,
          percentage: percentage,
          timeTaken: useTimer ? (totalTimeSeconds - _timeLeft) : null,
        ),
      ),
    );
  }

  Widget _buildQuestionWidget(QuizQuestionModel question) {
    switch (question.type) {
      case QuestionType.multipleChoice:
        return MultipleChoiceWidget(
          question: question,
          onAnswered: (correct) => _answerQuestion(correct),
        );
      case QuestionType.dragAndDrop:
        return DragAndDropWidget(
          question: question,
          onAnswered: (correct) => _answerQuestion(correct),
        );
      case QuestionType.matching:
        return MatchingQuizWidget(
          question: question,
          onAnswered: (correct) => _answerQuestion(correct),
        );
      default:
        return const Center(child: Text('Unknown question type'));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: useTimer
          ? AppBar(
        title: Text('Topic: ${_formatTopicName(widget.topic)}'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                _formatTime(_timeLeft),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      )
          : AppBar(
        title: Text('Topic: ${_formatTopicName(widget.topic)}'),
      ),
      body: FutureBuilder<List<QuizQuestionModel>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading questions'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No questions available.'));
          }

          if (_questions.isEmpty) {
            _questions = snapshot.data!;
            if (useTimer && _timeLeft > 0) {
              // Start timer once questions are loaded
              _startTimer();
            }
          }

          final question = _questions[_currentQuestionIndex];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ProgressBar(
                  current: _currentQuestionIndex + 1,
                  total: _questions.length,
                ),
                const SizedBox(height: 16),
                Expanded(child: _buildQuestionWidget(question)),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatTopicName(String topicKey) {
    return topicKey
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
