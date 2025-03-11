import 'package:flutter/material.dart';
import '../../../core/theme/text_styles.dart';

class FlashcardHeader extends StatelessWidget implements PreferredSizeWidget {
  final String topic;

  const FlashcardHeader({
    super.key,
    required this.topic,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FLASHCARD',
            style: AppTextStyles.headline.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          Text(
            _formatTopicName(topic),
            style: AppTextStyles.caption.copyWith(
              fontSize: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTopicName(String topic) {
    return topic.replaceAll('_', ' ').toUpperCase();
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
