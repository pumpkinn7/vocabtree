import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:vocabtree/features/vocab/widgets/letter_group_header.dart';
import 'package:vocabtree/features/vocab/widgets/topic_header.dart';
import 'package:vocabtree/features/vocab/widgets/word_list_item.dart';

class TopicWordListSection extends StatelessWidget {
  final String topic;
  final String formattedTopic;
  final Map<String, List<String>> sortedWords;
  final Function(String) onWordTap;

  const TopicWordListSection({
    super.key,
    required this.topic,
    required this.formattedTopic,
    required this.sortedWords,
    required this.onWordTap,
  });

  @override
  Widget build(BuildContext context) {
    if (sortedWords.isEmpty) {
      return const SizedBox.shrink();
    }

    return BootstrapContainer(
      fluid: true,
      children: [
        BootstrapRow(
          children: [
            BootstrapCol(
              sizes: 'col-12',
              child: TopicHeader(topicName: formattedTopic),
            ),
          ],
        ),
        ...sortedWords.entries.map((entry) {
          final letter = entry.key;
          final words = entry.value;

          return BootstrapRow(
            children: [
              BootstrapCol(
                sizes: 'col-12',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LetterGroupHeader(letter: letter),
                    ...words.map((word) => WordListItem(
                          word: word,
                          onTap: () => onWordTap(word),
                        )),
                  ],
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}
