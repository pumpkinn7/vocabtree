import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class ResultWrongWords extends StatelessWidget {
  final List<Map<String, dynamic>> wrongWords;
  final VoidCallback onViewAllPressed;

  const ResultWrongWords({
    super.key,
    required this.wrongWords,
    required this.onViewAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (wrongWords.isEmpty) {
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
            children: [
              Icon(
                Icons.check_circle_outline,
                color: colorScheme.primary,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'ยินดีด้วย! คุณไม่มีคำตอบที่ผิด',
                style: AppTextStyles.subtitle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // จำกัดจำนวนคำที่จะแสดงในหน้าสรุปผล
    final displayWords = wrongWords.take(5).toList();
    final hasMore = wrongWords.length > 5;

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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: colorScheme.error,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'คำศัพท์ที่ตอบผิดบ่อย',
                  style: AppTextStyles.subtitle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // แสดงรายการคำที่ตอบผิด
            ...displayWords
                .map((word) => _buildWrongWordItem(word, colorScheme)),

            if (hasMore) ...[
              const SizedBox(height: 16),
              Center(
                child: TextButton.icon(
                  onPressed: onViewAllPressed,
                  icon: const Icon(Icons.format_list_bulleted),
                  label: const Text('แสดงทั้งหมด'),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWrongWordItem(
      Map<String, dynamic> word, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: colorScheme.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              word['word'],
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${word['wrongCount']} ครั้ง',
              style: AppTextStyles.caption.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
