import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:lottie/lottie.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import 'package:vocabtree/features/quiz/widgets/quiz_content_widget.dart';
import 'package:vocabtree/features/quiz/widgets/slide_up_panel.dart';

import '../models/quiz_question_model.dart';
import '../services/firebase_service.dart';
import '../services/quiz_logic.dart';
import '../services/result_service.dart';
import '../widgets/exit_confirmation_dialog.dart';
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
  Set<String> _topFiveWrongWords = {};
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

      final sortedWrongWords = List.of(wrongWords);
      sortedWrongWords.sort(
          (a, b) => (b['wrongCount'] as int).compareTo(a['wrongCount'] as int));

      _topFiveWrongWords =
          sortedWrongWords.take(5).map((w) => w['word'] as String).toSet();
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
        wrongAnswers.add(currentQuestion);
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

    setState(() => _isQuizFinished = true);

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

  bool _hasSelectedAnswer() => _selectedAnswers[_currentQuestionIndex] != null;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_isQuizFinished) {
          return await showDialog<bool>(
                context: context,
                builder: (context) => const ExitConfirmationDialog(),
              ) ??
              false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _formatTopicName(widget.topic),
            style: AppTextStyles.headline,
          ),
        ),
        body: FutureBuilder<List<QuizQuestionModel>>(
          future: _questionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: Lottie.asset(
                        'assets/animations/Animation - 1741196193367.json',
                        frameRate: FrameRate.max,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "กำลังจัดเตรียมคำถาม...",
                      style: AppTextStyles.subtitle,
                    ),
                  ],
                ),
              );
            }

            final data = snapshot.data ?? [];
            if (_questions.isEmpty) {
              _questions = data;
            }

            // แสดงเนื้อหาเมื่อโหลดเสร็จแล้ว
            return BootstrapContainer(
              fluid: true,
              padding: const EdgeInsets.all(16.0),
              children: [
                BootstrapRow(
                  children: [
                    BootstrapCol(
                      sizes: 'col-12',
                      child: _buildQuizContent(),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuizContent() {
    final question = _questions[_currentQuestionIndex];

    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height -
              AppBar().preferredSize.height -
              MediaQuery.of(context).padding.top -
              32,
          child: QuizContentWidget(
            question: question,
            currentQuestionIndex: _currentQuestionIndex,
            totalQuestions: _questions.length,
            selectedAnswer: _selectedAnswers[_currentQuestionIndex],
            isAnswerChecked: _isAnswerChecked,
            isCorrect: _isAnswerCorrect,
            isFrequentlyWrong: _topFiveWrongWords.contains(question.mainWord),
            wrongCount:
                _wrongWordsStats[question.mainWord]?['wrongCount'] as int? ?? 0,
            onOptionSelected: (option) {
              setState(() {
                _selectedAnswers[_currentQuestionIndex] = option;
              });
            },
            onCheckAnswer: _hasSelectedAnswer() ? _checkAnswer : null,
            onSkipQuestion: _skipQuestion,
          ),
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
              topic: widget.topic,
            ),
          ),
      ],
    );
  }

  String _formatTopicName(String topicKey) {
    return topicKey
        .split('_')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }
}
