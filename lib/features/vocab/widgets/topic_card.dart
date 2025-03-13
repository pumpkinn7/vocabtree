import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import 'package:vocabtree/features/vocab/screens/all_vocab_screen.dart';
import 'package:vocabtree/features/vocab/screens/flashcard_for_review_screen.dart';
import 'package:vocabtree/features/vocab/services/vocab_service.dart';
import 'package:vocabtree/features/vocab/widgets/vocab_word_button.dart';

class TopicCard extends StatelessWidget {
  final String topic;
  final List<String> wordsList;
  final String level;
  final String userId;
  final Function(String, String, String) onRemoveWord;
  final Function(String) onShowCompletionMessage;
  final Function() onRefreshData;

  const TopicCard({
    super.key,
    required this.topic,
    required this.wordsList,
    required this.level,
    required this.userId,
    required this.onRemoveWord,
    required this.onShowCompletionMessage,
    required this.onRefreshData,
  });

  @override
  Widget build(BuildContext context) {
    final formattedTopic = VocabService.formatTopicName(topic);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formattedTopic,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            BootstrapRow(
              children: [
                BootstrapCol(
                  sizes: 'col-6',
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllVocabScreen(level: level),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colorScheme.outline),
                    ),
                    child: Text('ดูทั้งหมด'),
                  ),
                ),
                BootstrapCol(
                  sizes: 'col-6',
                  child: OutlinedButton(
                    onPressed: () => _openFlashcardReview(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colorScheme.outline),
                    ),
                    child: Text('Flashcard'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: wordsList.map((word) {
                return VocabWordButton(
                  word: word,
                  level: level,
                  topic: topic,
                  userId: userId,
                  onRemoveWord: onRemoveWord,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openFlashcardReview(BuildContext context) async {
    final vocabService = VocabService();
    final vocabDocs = await vocabService.getVocabDocsFromReviewWords(
      userId,
      level,
      topic,
      wordsList,
    );

    if (!context.mounted) return;

    if (vocabDocs.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('ไม่พบข้อมูลคำศัพท์')));
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlashcardForReviewScreen(
          level: level,
          topic: topic,
          userId: userId,
          vocabDocs: vocabDocs,
        ),
      ),
    );

    if (result == true) {
      onShowCompletionMessage(topic);
    }

    onRefreshData();
  }
}
