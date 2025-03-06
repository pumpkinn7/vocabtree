import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import 'package:vocabtree/features/quiz/screens/cefr_level_screen.dart';
import 'package:vocabtree/features/quiz/services/vocabulary_service.dart';
import 'package:vocabtree/features/quiz/widgets/daily_vocabulary_card.dart';
import 'package:vocabtree/features/quiz/widgets/vocabulary_item_widget.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vocabularyService = VocabularyService();
    final categories = vocabularyService.getVocabularyCategories();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('แบบทดสอบคำศัพท์ภาษาอังกฤษ', style: AppTextStyles.headline),
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
                  sizes: 'col-12',
                  child: const DailyVocabularyCard(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Categories Header
            BootstrapRow(
              children: [
                BootstrapCol(
                  sizes: 'col-12',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'หมวดหมู่คำศัพท์',
                      style: AppTextStyles.subtitle,
                    ),
                  ),
                ),
              ],
            ),

            // Vocabulary Categories
            ...categories.map((category) => BootstrapRow(
                  children: [
                    BootstrapCol(
                      sizes: 'col-12',
                      child: VocabularyItemWidget(
                        title: category.title,
                        level: category.level,
                        difficulty: category.difficulty,
                        imagePath: category.imagePath,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CefrLevelScreen(
                                cefrLevel: category.cefrLevel,
                                userId: userId,
                              ),
                            ),
                          );
                        },
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
