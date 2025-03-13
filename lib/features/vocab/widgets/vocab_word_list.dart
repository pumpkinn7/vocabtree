import 'package:flutter/material.dart';
import 'package:vocabtree/features/vocab/widgets/vocab_word_button.dart';

class VocabWordList extends StatelessWidget {
  final List<String> wordsList;
  final String level;
  final String topic;
  final String userId;
  final Function(String, String, String) onRemoveWord;

  const VocabWordList({
    super.key,
    required this.wordsList,
    required this.level,
    required this.topic,
    required this.userId,
    required this.onRemoveWord,
  });

  @override
  Widget build(BuildContext context) {
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
}
