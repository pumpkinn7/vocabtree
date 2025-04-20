import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import 'package:vocabtree/features/vocab/screens/filter_screen.dart';

class DictionarySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback? onFilterTap;
  final Function(Map<String, dynamic>)? onFilterApplied;
  final Map<String, dynamic>? activeFilters;

  const DictionarySearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onFilterTap,
    this.onFilterApplied,
    this.activeFilters,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // จำนวนตัวกรองที่เลือก
    final int activeFilterCount = _getActiveFilterCount();

    return Row(
      children: [
        Expanded(
          child: Padding(
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
          ),
        ),
        InkWell(
          onTap: () async {
            if (onFilterTap != null) {
              onFilterTap!();
            } else {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const FilterScreen(),
                ),
              );

              if (result != null &&
                  result is Map<String, dynamic> &&
                  onFilterApplied != null) {
                onFilterApplied!(result);
              }
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.only(right: 8.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: activeFilterCount > 0
                  ? colorScheme.primary
                  : colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.filter_list,
              color: activeFilterCount > 0
                  ? colorScheme.onPrimary
                  : colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  // คำนวณจำนวนของตัวกรองที่เลือก
  int _getActiveFilterCount() {
    if (activeFilters == null) return 0;

    int count = 0;
    if (activeFilters!.containsKey('cefrLevels')) {
      count += (activeFilters!['cefrLevels'] as List).isNotEmpty ? 1 : 0;
    }
    if (activeFilters!.containsKey('topics')) {
      count += (activeFilters!['topics'] as List).isNotEmpty ? 1 : 0;
    }
    if (activeFilters!.containsKey('partOfSpeech')) {
      count += (activeFilters!['partOfSpeech'] as List).isNotEmpty ? 1 : 0;
    }
    return count;
  }
}
