import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import 'package:vocabtree/features/quiz/services/firebase_service.dart';
import 'package:vocabtree/features/quiz/widgets/all_wrong_words_dialog.dart';
import 'package:vocabtree/features/quiz/widgets/result_summary_card.dart';
import 'package:vocabtree/features/quiz/widgets/result_wrong_words.dart';
import 'package:vocabtree/features/quiz/widgets/result_action_buttons.dart';

import '../../quiz/screens/quiz_topic_screen.dart';
import '../models/quiz_question_model.dart';
import '../models/quiz_result.dart';
import '../services/result_service.dart';

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
  List<Map<String, dynamic>> topWrongWords = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (user == null) return;

    try {
      final result = QuizResult(
        userId: user!.uid,
        topic: widget.topic,
        score: widget.score,
        totalQuestions: widget.totalQuestions,
        percentage: widget.percentage,
        wrongAnswers: widget.wrongAnswers.map((q) => q.mainWord).toList(),
      );

      await ResultService.saveQuizResult(result);

      final wrongWords = await ResultService.getTopWrongWords(
        user!.uid,
        topic: widget.topic,
      );

      if (mounted) {
        setState(() {
          topWrongWords = wrongWords;
          isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showAllWrongWords() {
    showDialog(
      context: context,
      builder: (context) => AllWrongWordsDialog(
        userId: user?.uid ?? '',
        topic: widget.topic,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('ผลการทำแบบทดสอบ', style: AppTextStyles.headline),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text('กำลังประมวลผล...', style: AppTextStyles.body),
                ],
              ),
            )
          : SingleChildScrollView(
              child: BootstrapContainer(
                fluid: true,
                decoration: BoxDecoration(
                  color: theme.colorScheme.background,
                ),
                padding: const EdgeInsets.all(16.0),
                children: [
                  // สรุปผลการทำแบบทดสอบ
                  BootstrapRow(
                    children: [
                      BootstrapCol(
                        sizes: 'col-xs-10 col-sm-10 col-md-6 col-lg-6',
                        offsets:
                            'offset-xs-1 offset-sm-1 offset-md-3 offset-lg-3',
                        child: ResultSummaryCard(
                          topic: widget.topic,
                          score: widget.score,
                          totalQuestions: widget.totalQuestions,
                          percentage: widget.percentage,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // คำที่ตอบผิดบ่อย
                  BootstrapRow(
                    children: [
                      BootstrapCol(
                        sizes: 'col-xs-10 col-sm-10 col-md-6 col-lg-6',
                        offsets:
                            'offset-xs-1 offset-sm-1 offset-md-3 offset-lg-3',
                        child: ResultWrongWords(
                          wrongWords: topWrongWords,
                          onViewAllPressed: _showAllWrongWords,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ปุ่มดำเนินการ
                  BootstrapRow(
                    children: [
                      BootstrapCol(
                        sizes: 'col-xs-10 col-sm-10 col-md-6 col-lg-6',
                        offsets:
                            'offset-xs-1 offset-sm-1 offset-md-3 offset-lg-3',
                        child: ResultActionButtons(
                          percentage: widget.percentage,
                          onGoBack: () => Navigator.pop(context),
                          onNextTopic:
                              widget.percentage >= 60.0 ? _goToNextTopic : null,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
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
}
