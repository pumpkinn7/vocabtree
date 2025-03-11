import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class ResultSummaryWidget extends StatelessWidget {
  final String topic;
  final int score;
  final int totalQuestions;

  const ResultSummaryWidget({
    super.key,
    required this.topic,
    required this.score,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'หมวดหมู่: ${_formatTopicName(topic)}',
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'คะแนน',
                  style: AppTextStyles.body,
                ),
                Text(
                  '$score / $totalQuestions',
                  style: AppTextStyles.subtitle.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTopicName(String topicKey) {
    return topicKey
        .split('_')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}
