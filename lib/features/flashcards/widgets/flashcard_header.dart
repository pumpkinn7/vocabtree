import 'package:flutter/material.dart';

class FlashcardHeader extends StatelessWidget implements PreferredSizeWidget {
  final String topic;

  const FlashcardHeader({
    super.key,
    required this.topic,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FLASHCARD',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          Text(
            '${topic.replaceAll('_', ' ').toUpperCase()}.',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
