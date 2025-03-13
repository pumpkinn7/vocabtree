import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class DictionarySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const DictionarySearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'ค้นหาคำศัพท์...',
          prefixIcon: Icon(Icons.search, color: colorScheme.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          filled: true,
          fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
        ),
        style: AppTextStyles.body,
        onChanged: onChanged,
      ),
    );
  }
}
