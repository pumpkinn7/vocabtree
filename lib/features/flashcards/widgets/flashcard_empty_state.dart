import 'package:flutter/material.dart';
import '../../../core/theme/text_styles.dart';

class FlashcardEmptyState extends StatelessWidget {
  const FlashcardEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.content_paste_off_rounded,
                size: 64,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'ไม่มีคำศัพท์ให้เรียน',
                style: AppTextStyles.subtitle.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'คุณได้เรียนรู้คำศัพท์ทั้งหมดในหมวดนี้แล้ว',
                style: AppTextStyles.body.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
