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

  bool _isQuizFinished = false;
  bool _isAnswerChecked = false;
  bool _isAnswerCorrect = false;

  // Track selected answers
  final Map<int, dynamic> _selectedAnswers = {}; // key: question index, value: selected answer

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

  void _checkAnswer() {
    if (_isAnswerChecked) return;

    final currentQuestion = _questions[_currentQuestionIndex];
    final selectedAnswer = _selectedAnswers[_currentQuestionIndex];

    bool correct = false;

    switch (currentQuestion.type) {
      case QuestionType.multipleChoice:
        correct = selectedAnswer == currentQuestion.correctAnswer;
        break;
      case QuestionType.dragAndDrop:
      case QuestionType.matching:
        if (selectedAnswer is Map<String, String?>) {
          correct = true;
          currentQuestion.correctMatches.forEach((key, value) {
            if (selectedAnswer[key] != value) {
              correct = false;
            }
          });
        }
        break;
    }

    setState(() {
      _isAnswerChecked = true;
      _isAnswerCorrect = correct;
      if (correct) {
        _score++;
      }
    });
  }

  void _skipQuestion() {
    if (_isAnswerChecked) return;

    setState(() {
      _isAnswerChecked = true;
      _isAnswerCorrect = false;
    });
  }

  void _nextQuestion() {
    if (!_isAnswerChecked) return;

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswerChecked = false;
        _isAnswerCorrect = false;
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

  Widget _buildQuestionWidget(QuizQuestionModel question, int index) {
    switch (question.type) {
      case QuestionType.multipleChoice:
        return MultipleChoiceWidget(
          question: question,
          selectedOption: _selectedAnswers[index],
          onOptionSelected: (option) {
            setState(() {
              _selectedAnswers[index] = option;
            });
          },
          isAnswerChecked: _isAnswerChecked,
          isCorrect: _isAnswerCorrect,
        );
      case QuestionType.dragAndDrop:
        return DragAndDropWidget(
          question: question,
          userMatches: _selectedAnswers[index] ?? {},
          onUpdateMatches: (matches) {
            setState(() {
              _selectedAnswers[index] = matches;
            });
          },
          isAnswerChecked: _isAnswerChecked,
          isCorrect: _isAnswerCorrect,
        );
      case QuestionType.matching:
        return MatchingQuizWidget(
          question: question,
          userMatches: _selectedAnswers[index] ?? {},
          onUpdateMatches: (matches) {
            setState(() {
              _selectedAnswers[index] = matches;
            });
          },
          isAnswerChecked: _isAnswerChecked,
          isCorrect: _isAnswerCorrect,
        );
      default:
        return const Center(child: Text('Unknown question type'));
    }
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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<QuizQuestionModel>>(
            future: _questionsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text('Error loading topics'));
              }

              final data = snapshot.data ?? [];
              if (data.isEmpty) {
                return const Center(child: Text('No questions available.'));
              }

              if (_questions.isEmpty) {
                _questions = data;
                if (useTimer && _timeLeft > 0) {
                  _startTimer();
                }
              }

              final question = _questions[_currentQuestionIndex];

              return Column(
                children: [
                  ProgressBar(
                    current: _currentQuestionIndex + 1,
                    total: _questions.length,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildQuestionWidget(question, _currentQuestionIndex),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ปุ่มด้านล่าง
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _isAnswerChecked ? null : _skipQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          minimumSize: const Size(100, 50),
                        ),
                        child: const Text('ข้าม'),
                      ),
                      ElevatedButton(
                        onPressed: (_isAnswerChecked || _hasAnswered()) // เพิ่มเงื่อนไขนี้
                            ? _nextQuestion
                            : (_hasSelectedAnswer() ? _checkAnswer : null),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (_isAnswerChecked || _hasAnswered())
                              ? Colors.blue
                              : Colors.green,
                          minimumSize: const Size(100, 50),
                        ),
                        child: Text(_isAnswerChecked ? 'ถัดไป' : 'ตรวจ'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// เช็คว่าผู้ใช้ได้เลือกคำตอบหรือยัง
  bool _hasSelectedAnswer() {
    final currentQuestion = _questions[_currentQuestionIndex];
    switch (currentQuestion.type) {
      case QuestionType.multipleChoice:
        return _selectedAnswers[_currentQuestionIndex] != null;
      case QuestionType.dragAndDrop:
      case QuestionType.matching:
        if (_selectedAnswers[_currentQuestionIndex] is Map<String, String?>) {
          return (_selectedAnswers[_currentQuestionIndex] as Map<String, String?>)
              .values
              .every((value) => value != null);
        }
        return false;
      default:
        return false;
    }
  }

  /// เช็คว่าผู้ใช้ได้ตอบคำถามในครั้งนี้แล้วหรือยัง (กรณีบางคำถามอาจต้องการการตอบหลายครั้ง)
  bool _hasAnswered() {
    return _isAnswerChecked;
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
