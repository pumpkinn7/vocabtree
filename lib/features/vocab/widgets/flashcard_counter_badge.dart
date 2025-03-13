import 'package:flutter/material.dart';
import '../../../core/theme/text_styles.dart';

class FlashcardCounterBadge extends StatelessWidget {
  final int currentCount;
  final int totalCount;

  const FlashcardCounterBadge({
    super.key,
    required this.currentCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // คำนวณค่าที่จะแสดง
    final displayCount = currentCount > totalCount ? totalCount : currentCount;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          '$displayCount / $totalCount',
          style: AppTextStyles.caption.copyWith(
            color: colorScheme.onPrimaryContainer,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
