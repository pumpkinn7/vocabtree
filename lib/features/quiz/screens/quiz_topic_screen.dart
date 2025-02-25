import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vocabtree/features/quiz/widgets/slide_up_panel.dart';

import '../models/quiz_question_model.dart';
import '../services/firebase_service.dart';
import '../services/quiz_logic.dart';
import '../services/result_service.dart';
import '../widgets/multiple_choice_widget.dart';
import '../widgets/progress_bar.dart';
import 'result_screen.dart';

class QuizTopicScreen extends StatefulWidget {
  final String topic;
  final String cefrLevel;

  const QuizTopicScreen(
      {super.key, required this.topic, required this.cefrLevel});

  @override
  State<QuizTopicScreen> createState() => _QuizTopicScreenState();
}

class _QuizTopicScreenState extends State<QuizTopicScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  late Future<List<QuizQuestionModel>> _questionsFuture;

  List<QuizQuestionModel> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;

  bool _isQuizFinished = false;
  bool _isAnswerChecked = false;
  bool _isAnswerCorrect = false;

  final List<QuizQuestionModel> wrongAnswers = [];

  final Map<int, dynamic> _selectedAnswers = {};
  Set<String> _frequentlyWrongWords = {};
  Map<String, Map<String, dynamic>> _wrongWordsStats = {};

  @override
  void initState() {
    super.initState();
    _questionsFuture = _loadQuestionsAndStats();
  }

  Future<List<QuizQuestionModel>> _loadQuestions() async {
    if (kDebugMode) {
      print(
          'Loading questions for topic: ${widget.topic}, CEFR Level: ${widget.cefrLevel}');
    }

    final allQuestions = await FirebaseService.getQuestionsForTopic(
        widget.cefrLevel, widget.topic);
    return QuizLogic.arrangeAndShuffleQuestions(allQuestions);
  }

  Future<List<QuizQuestionModel>> _loadQuestionsAndStats() async {
    final questions = await _loadQuestions();

    if (user != null) {
      final wrongWords = await ResultService.getTopWrongWords(
        user!.uid,
        limit: 100,
        topic: widget.topic,
      );

      _wrongWordsStats = {
        for (var word in wrongWords) word['word'] as String: word,
      };

      _frequentlyWrongWords =
          wrongWords.map((w) => w['word'] as String).toSet();
    }

    return questions;
  }

  void _checkAnswer() {
    if (_isAnswerChecked) return;

    final currentQuestion = _questions[_currentQuestionIndex];
    final selectedAnswer = _selectedAnswers[_currentQuestionIndex];

    bool correct = selectedAnswer == currentQuestion.mainWord;

    setState(() {
      _isAnswerChecked = true;
      _isAnswerCorrect = correct;
      if (correct) {
        _score++;
      } else {
        wrongAnswers.add(currentQuestion); // เพิ่มคำที่ตอบผิดเข้าไปในลิสต์
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
    final correctAnswers = _score;
    final totalQuestions = _questions.length;
    final percentage = (correctAnswers / totalQuestions) * 100;

    setState(() {
      _isQuizFinished = true;
    });

    if (user != null) {
      FirebaseService.manageProgress(
        user!.uid,
        widget.cefrLevel,
        widget.topic,
        percentage,
      );
    }

    Map<String, int> cefrDistribution = {};
    for (var question in _questions) {
      final cefr = question.senses[0]['cefr'] as String? ?? 'N/A';
      cefrDistribution[cefr] = (cefrDistribution[cefr] ?? 0) + 1;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          cefrLevel: widget.cefrLevel,
          topic: widget.topic,
          score: correctAnswers,
          totalQuestions: totalQuestions,
          percentage: percentage,
          cefrDistribution: cefrDistribution,
          wrongAnswers: wrongAnswers,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _hasSelectedAnswer() {
    return _selectedAnswers[_currentQuestionIndex] != null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_isQuizFinished) {
          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('ยืนยันการออก'),
              content: const Text(
                  'คุณยังทำ Quiz ไม่เสร็จ ต้องการออกหรือไม่? คะแนนจะไม่ถูกบันทึก'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('ยกเลิก'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('ออก'),
                ),
              ],
            ),
          );
          return shouldExit ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              'หมวดหมู่: ${_formatTopicName(widget.topic)}'), // เปลี่ยนจาก Topic:
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
                return const Center(child: Text('Error loading questions'));
              }

              final data = snapshot.data ?? [];
              if (data.isEmpty) {
                return const Center(child: Text('No questions available.'));
              }

              if (_questions.isEmpty) {
                _questions = data;
              }

              final question = _questions[_currentQuestionIndex];

              return Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            ProgressBar(
                              current: _currentQuestionIndex + 1,
                              total: _questions.length,
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: SingleChildScrollView(
                                child: _buildQuestionWidget(
                                    question, _currentQuestionIndex),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!_isAnswerChecked)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: _skipQuestion,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  minimumSize: const Size(100, 50),
                                ),
                                child: const Text('ข้าม'),
                              ),
                              ElevatedButton(
                                onPressed:
                                    _hasSelectedAnswer() ? _checkAnswer : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  minimumSize: const Size(100, 50),
                                ),
                                child: const Text('ตรวจ'),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  if (_isAnswerChecked)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: SlideUpPanel(
                        isCorrect: _isAnswerCorrect,
                        correctAnswer: question.mainWord,
                        onNextPressed: _nextQuestion,
                      ),
                    ),
                ],
              );
            },
          ),
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

  Widget _buildQuestionWidget(QuizQuestionModel question, int index) {
    final isFrequentlyWrong = _frequentlyWrongWords.contains(question.mainWord);
    // ค้นหาจำนวนครั้งที่ตอบผิดจาก wrongWords
    final wrongCount =
        _wrongWordsStats[question.mainWord]?['wrongCount'] as int? ?? 0;

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
      isFrequentlyWrong: isFrequentlyWrong,
      wrongCount: wrongCount, // เพิ่ม parameter นี้
    );
  }
}
