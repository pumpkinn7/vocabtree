import 'package:flutter/material.dart';
import '../../../core/theme/text_styles.dart';

class FlashcardCounter extends StatelessWidget {
  final int currentIndex;
  final int totalCount;

  const FlashcardCounter({
    super.key,
    required this.currentIndex,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$currentIndex of $totalCount',
              style: AppTextStyles.caption.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
