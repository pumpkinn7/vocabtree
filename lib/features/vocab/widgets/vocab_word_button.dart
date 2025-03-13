import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import 'package:vocabtree/features/vocab/services/vocab_service.dart';
import 'package:vocabtree/features/vocab/widgets/vocab_detail_dialog.dart';

class VocabWordButton extends StatelessWidget {
  final String word;
  final String level;
  final String topic;
  final String userId;
  final Function(String, String, String) onRemoveWord;

  const VocabWordButton({
    super.key,
    required this.word,
    required this.level,
    required this.topic,
    required this.userId,
    required this.onRemoveWord,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return OutlinedButton(
      onPressed: () => _showWordDetail(context),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        side: BorderSide(color: colorScheme.primary),
      ),
      child: Text(
        word,
        textAlign: TextAlign.center,
        style: AppTextStyles.buttonText.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  Future<void> _showWordDetail(BuildContext context) async {
    final vocabService = VocabService();
    final vocabData = await vocabService.getVocabDataForWord(
      userId,
      level,
      topic,
      word,
    );

    if (!context.mounted) return;

    if (vocabData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่พบข้อมูลสำหรับคำว่า "$word"')),
      );
      return;
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => VocabDetailDialog(
        wordId: word,
        vocabData: vocabData,
        level: level,
        topic: topic,
        userId: userId,
        onRemoveWord: (word) => onRemoveWord(level, topic, word),
      ),
    );
  }
}
