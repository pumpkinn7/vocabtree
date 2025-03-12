import 'package:flutter/material.dart';
import '../../../core/theme/text_styles.dart';

class SummaryActionButtons extends StatelessWidget {
  final VoidCallback onRestart;
  final VoidCallback onReset;

  const SummaryActionButtons({
    super.key,
    required this.onRestart,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              onPressed: onRestart,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('ทบทวนต่อ', style: AppTextStyles.buttonText),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: OutlinedButton(
              onPressed: onReset,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('รีเซ็ต',
                  style: AppTextStyles.buttonText.copyWith(color: Colors.red)),
            ),
          ),
        ),
      ],
    );
  }
}
