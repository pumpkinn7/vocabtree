import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class TopicHeader extends StatelessWidget {
  final String topicName;

  const TopicHeader({
    super.key,
    required this.topicName,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Text(
        topicName,
        style: AppTextStyles.subtitle.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
