import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import 'package:vocabtree/features/vocab/screens/all_vocab_screen.dart';
import 'package:vocabtree/features/vocab/screens/flashcard_for_review_screen.dart';
import 'package:vocabtree/features/vocab/services/vocab_service.dart';
import 'package:vocabtree/features/vocab/widgets/vocab_word_button.dart';

class TopicSection extends StatelessWidget {
  final String level;
  final String topic;
  final List<String> wordsList;
  final String userId;
  final Function(String, String, String) onRemoveWord;
  final Function(String) onShowCompletionMessage;
  final Function() onRefreshData;

  const TopicSection({
    super.key,
    required this.level,
    required this.topic,
    required this.wordsList,
    required this.userId,
    required this.onRemoveWord,
    required this.onShowCompletionMessage,
    required this.onRefreshData,
  });

  @override
  Widget build(BuildContext context) {
    final vocabService = VocabService();
    final formattedTopic = VocabService.formatTopicName(topic);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              // ปุ่ม "ดูทั้งหมด"
              BootstrapCol(
                sizes: 'col-xs-6 col-sm-6 col-md-6 col-lg-4',
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllVocabScreen(level: level),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colorScheme.outline),
                  ),
                  child: Text('ดูทั้งหมด', style: AppTextStyles.buttonText),
                ),
              ),

              // ปุ่ม "Flashcard"
              BootstrapCol(
                sizes: 'col-xs-6 col-sm-6 col-md-6 col-lg-4',
                child: OutlinedButton(
                  onPressed: () => _openFlashcardReview(context, vocabService),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colorScheme.outline),
                  ),
                  child: Text('Flashcard', style: AppTextStyles.buttonText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildWordsList(context),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildWordsList(BuildContext context) {
    return Wrap(
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
    );
  }

  Future<void> _openFlashcardReview(
      BuildContext context, VocabService vocabService) async {
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

    // หากคืนค่า result เป็น true แสดงว่าเสร็จสมบูรณ์
    if (result == true) {
      onShowCompletionMessage(topic);
    }

    onRefreshData();
  }
}
