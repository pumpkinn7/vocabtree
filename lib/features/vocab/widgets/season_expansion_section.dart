import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import 'package:vocabtree/features/vocab/widgets/topic_section.dart';

class SeasonExpansionSection extends StatelessWidget {
  final String level;
  final String seasonName;
  final String seasonImage;
  final List<String> topics;
  final Map<String, List<String>> reviewWordsForLevel;
  final String userId;
  final Function(String, String, String) onRemoveWord;
  final Function(String) onShowCompletionMessage;
  final Function() onRefreshData;

  const SeasonExpansionSection({
    super.key,
    required this.level,
    required this.seasonName,
    required this.seasonImage,
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

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // ภาพพื้นหลัง
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                seasonImage,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // เนื้อหา
          ExpansionTile(
            title: Text(
              seasonName,
              style: AppTextStyles.subtitle,
            ),
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            collapsedIconColor: colorScheme.primary,
            iconColor: colorScheme.primary,
            childrenPadding: const EdgeInsets.only(bottom: 8),
            children: [
              ...topicsWithWords.map((topic) => TopicSection(
                    level: level,
                    topic: topic,
                    wordsList: reviewWordsForLevel[topic] ?? [],
                    userId: userId,
                    onRemoveWord: onRemoveWord,
                    onShowCompletionMessage: onShowCompletionMessage,
                    onRefreshData: onRefreshData,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
