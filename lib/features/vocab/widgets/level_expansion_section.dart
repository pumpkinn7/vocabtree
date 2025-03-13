import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:vocabtree/features/vocab/widgets/topic_section.dart';

class LevelExpansionSection extends StatelessWidget {
  final String level;
  final List<String> topics;
  final Map<String, List<String>> reviewWordsForLevel;
  final String userId;
  final Function(String, String, String) onRemoveWord;
  final Function(String) onShowCompletionMessage;
  final Function() onRefreshData;

  const LevelExpansionSection({
    super.key,
    required this.level,
    required this.topics,
    required this.reviewWordsForLevel,
    required this.userId,
    required this.onRemoveWord,
    required this.onShowCompletionMessage,
    required this.onRefreshData,
  });

  @override
  Widget build(BuildContext context) {
    // กรองเฉพาะหัวข้อที่มีคำศัพท์
    final topicsWithWords = topics
        .where((topic) => (reviewWordsForLevel[topic]?.isNotEmpty) ?? false)
        .toList();

    if (topicsWithWords.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return ExpansionTile(
      title: Text(
        'ระดับ: $level',
        style: AppTextStyles.subtitle.copyWith(color: colorScheme.primary),
      ),
      children: [
        BootstrapContainer(
          fluid: true,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          children: [
            ...topicsWithWords.map((topic) => BootstrapRow(
                  children: [
                    BootstrapCol(
                      sizes: 'col-xs-12 col-sm-12 col-md-10 col-lg-8',
                      offsets:
                          'offset-xs-0 offset-sm-0 offset-md-1 offset-lg-2',
                      child: TopicSection(
                        level: level,
                        topic: topic,
                        wordsList: reviewWordsForLevel[topic] ?? [],
                        userId: userId,
                        onRemoveWord: onRemoveWord,
                        onShowCompletionMessage: onShowCompletionMessage,
                        onRefreshData: onRefreshData,
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ],
    );
  }
}
