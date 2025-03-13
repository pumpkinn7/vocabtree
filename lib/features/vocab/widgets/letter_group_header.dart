import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class LetterGroupHeader extends StatelessWidget {
  final String letter;

  const LetterGroupHeader({
    super.key,
    required this.letter,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              letter,
              style: AppTextStyles.caption.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Divider(
                color: colorScheme.primary.withOpacity(0.7), thickness: 1),
          ),
        ],
      ),
    );
  }
}
