import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class WordListItem extends StatelessWidget {
  final String word;
  final VoidCallback onTap;

  const WordListItem({
    super.key,
    required this.word,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      title: Text(word, style: AppTextStyles.body),
      trailing: IconButton(
        icon: Icon(
          Icons.add_circle_outline,
          color: colorScheme.primary,
        ),
        onPressed: onTap,
        tooltip: 'เพิ่มคำศัพท์',
      ),
      onTap: onTap,
    );
  }
}
