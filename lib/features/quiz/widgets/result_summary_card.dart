import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class ResultSummaryCard extends StatelessWidget {
  final String topic;
  final int score;
  final int totalQuestions;
  final double percentage;

  const ResultSummaryCard({
    super.key,
    required this.topic,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // กำหนดสีตามผลการทำแบบทดสอบ
    final bool isPassed = percentage >= 60.0;
    final Color resultColor =
        isPassed ? AppTextStyles.primaryDarkColor : AppTextStyles.primaryColor;

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // หัวข้อ
            Text(
              _formatTopicName(topic),
              style: AppTextStyles.title.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            // คะแนน
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: resultColor.withOpacity(0.1),
                border: Border.all(
                  color: resultColor,
                  width: 3,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$score/$totalQuestions',
                      style: AppTextStyles.headline.copyWith(
                        color: resultColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: AppTextStyles.body.copyWith(
                        color: resultColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // สถานะการผ่าน/ไม่ผ่าน
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isPassed
                    ? AppTextStyles.primaryDarkColor.withOpacity(0.2)
                    : AppTextStyles.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                isPassed ? 'ผ่านการทดสอบ' : 'ไม่ผ่านการทดสอบ',
                style: AppTextStyles.body.copyWith(
                  color: isPassed
                      ? AppTextStyles.primaryDarkColor
                      : AppTextStyles.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
