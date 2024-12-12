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

  List<QuizQuestionModel> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;

  bool useTimer = true;
  int totalTimeSeconds = 300; // 5 นาที
  Timer? _timer;
  int _timeLeft = 0;

  String? _feedbackMessage;

  // เพิ่มตัวแปรเพื่อติดตามสถานะการทำ Quiz ว่าทำเสร็จหรือยัง
  bool _isQuizFinished = false;

  @override
  void initState() {
    super.initState();
    _questionsFuture = _loadQuestions();
    if (useTimer) {
      _timeLeft = totalTimeSeconds;
    }
  }

  Future<List<QuizQuestionModel>> _loadQuestions() async {
    final cefrLevel = await FirebaseService.getCEFRLevelForTopic(widget.topic);
    final allQuestions = await FirebaseService.getQuestionsForTopic(cefrLevel, widget.topic);
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
    setState(() {
      _feedbackMessage = correct ? 'ถูกต้อง!' : 'ตอบผิด!';
    });

    // กำหนดสีพื้นหลัง SnackBar ตามผลลัพธ์
    final snackBarColor = correct ? Colors.green : Colors.red;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_feedbackMessage!),
        duration: const Duration(seconds: 1),
        backgroundColor: snackBarColor,
      ),
    );

    if (correct) {
      _score++;
    }

    Future.delayed(const Duration(seconds: 1), () {
      _goToNextQuestionOrFinish();
    });
  }

  void _goToNextQuestionOrFinish() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _feedbackMessage = null;
      });
    } else {
      _submitQuiz();
    }
  }

  void _submitQuiz() {
    _timer?.cancel();
    final correctAnswers = _score;
    final totalQuestions = _questions.length;
    final percentage = (correctAnswers / totalQuestions) * 100;

    setState(() {
      _isQuizFinished = true;
    });

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
    Widget questionWidget;
    switch (question.type) {
      case QuestionType.multipleChoice:
        questionWidget = MultipleChoiceWidget(
          key: ValueKey('multiple_$_currentQuestionIndex'),
          question: question,
          onAnswered: (correct) => _answerQuestion(correct),
        );
        break;
      case QuestionType.dragAndDrop:
        questionWidget = DragAndDropWidget(
          key: ValueKey('drag_$_currentQuestionIndex'),
          question: question,
          onAnswered: (correct) => _answerQuestion(correct),
        );
        break;
      case QuestionType.matching:
        questionWidget = MatchingQuizWidget(
          key: ValueKey('matching_$_currentQuestionIndex'),
          question: question,
          onAnswered: (correct) => _answerQuestion(correct),
        );
        break;
      default:
        questionWidget = const Center(child: Text('Unknown question type'));
    }
    return questionWidget;
  }

  Future<bool> _onWillPop() async {
    if (!_isQuizFinished) {
      final shouldExit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('ยืนยันการออก'),
          content: const Text('คุณยังทำ Quiz ไม่เสร็จ ต้องการออกหรือไม่? คะแนนจะไม่ถูกบันทึก'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // ไม่ออก
              },
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // ออก
              },
              child: const Text('ออก'),
            ),
          ],
        ),
      );
      return shouldExit ?? false;
    }
    // ถ้า Quiz ทำเสร็จแล้ว ออกได้เลย
    return true;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // ดักจับการกด Back
      child: Scaffold(
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
