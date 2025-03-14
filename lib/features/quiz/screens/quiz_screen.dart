import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import 'package:vocabtree/features/quiz/screens/cefr_level_screen.dart';
import 'package:vocabtree/features/quiz/services/vocabulary_service.dart';
import 'package:vocabtree/features/quiz/widgets/daily_vocabulary_card.dart';
import 'package:vocabtree/features/quiz/widgets/vocabulary_guide_dialog.dart';
import 'package:vocabtree/features/quiz/widgets/vocabulary_item_widget.dart';
import '../widgets/quiz_loading.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _isLoading = true;
  final VocabularyService _vocabularyService = VocabularyService();
  late final List<dynamic> _categories;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final startTime = DateTime.now();

    _categories = _vocabularyService.getVocabularyCategories();

    final elapsedTime = DateTime.now().difference(startTime).inMilliseconds;
    final minimumLoadingTime = 3500;

    if (elapsedTime < minimumLoadingTime) {
      await Future.delayed(
        Duration(milliseconds: minimumLoadingTime - elapsedTime),
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showVocabGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const VocabularyGuideDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: QuizLoading(),
      );
    }

    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('แบบทดสอบคำศัพท์', style: AppTextStyles.headline),
      ),
      body: SingleChildScrollView(
        child: BootstrapContainer(
          fluid: true,
          padding: const EdgeInsets.all(16.0),
          children: [
            // Daily Vocabulary Card
            BootstrapRow(
              children: [
                BootstrapCol(
                  sizes: 'col-xs-12 col-sm-12 col-md-8 col-lg-6',
                  offsets: 'offset-xs-0 offset-sm-0 offset-md-2 offset-lg-3',
                  child: const DailyVocabularyCard(),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Categories Header with Help Button
            BootstrapRow(
              children: [
                BootstrapCol(
                  sizes: 'col-xs-12 col-sm-12 col-md-8 col-lg-6',
                  offsets: 'offset-xs-0 offset-sm-0 offset-md-2 offset-lg-3',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('หมวดหมู่คำศัพท์', style: AppTextStyles.subtitle),
                        IconButton(
                          icon: const Icon(Icons.help_outline),
                          tooltip: 'คู่มือระดับคำศัพท์',
                          onPressed: () => _showVocabGuide(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Vocabulary Categories with simplified layout
            ..._categories.map((category) => BootstrapRow(
                  children: [
                    BootstrapCol(
                      sizes: 'col-xs-12 col-sm-12 col-md-8 col-lg-6',
                      offsets:
                          'offset-xs-0 offset-sm-0 offset-md-2 offset-lg-3',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: VocabularyItemWidget(
                          title: category.title,
                          level: category.level,
                          difficulty: category.difficulty,
                          imagePath: category.imagePath,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CefrLevelScreen(
                                cefrLevel: category.cefrLevel,
                                userId: userId,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
