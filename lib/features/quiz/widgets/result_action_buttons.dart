import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class ResultActionButtons extends StatelessWidget {
  final double percentage;
  final VoidCallback onGoBack;
  final VoidCallback? onNextTopic;

  const ResultActionButtons({
    super.key,
    required this.percentage,
    required this.onGoBack,
    this.onNextTopic,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPassed = percentage >= 60.0;

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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // ปุ่มย้อนกลับ
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onGoBack,
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('ย้อนกลับ'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.surfaceVariant,
                      foregroundColor: colorScheme.onSurfaceVariant,
                      textStyle: AppTextStyles.buttonText,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // ปุ่มหัวข้อถัดไป
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isPassed ? onNextTopic : null,
                    icon: const Icon(Icons.navigate_next_rounded),
                    label: const Text('หัวข้อถัดไป'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      disabledBackgroundColor:
                          colorScheme.surfaceVariant.withOpacity(0.7),
                      disabledForegroundColor:
                          colorScheme.onSurfaceVariant.withOpacity(0.5),
                      textStyle: AppTextStyles.buttonText,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            if (!isPassed) ...[
              const SizedBox(height: 16),
              Text(
                'คะแนนอย่างน้อย 60% เพื่อปลดล็อกหัวข้อถัดไป',
                style: AppTextStyles.caption.copyWith(
                  color: colorScheme.error,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
