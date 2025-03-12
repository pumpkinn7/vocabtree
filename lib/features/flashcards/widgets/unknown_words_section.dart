import 'package:flutter/material.dart';
import '../../../core/theme/text_styles.dart';

class UnknownWordsSection extends StatelessWidget {
  final List<String> unknownWords;
  final Set<String> selectedWords;
  final Function(String) onToggleWord;
  final VoidCallback onAddToBank;
  final bool isAddingToBank;

  const UnknownWordsSection({
    super.key,
    required this.unknownWords,
    required this.selectedWords,
    required this.onToggleWord,
    required this.onAddToBank,
    required this.isAddingToBank,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool canAddToBank = selectedWords.isNotEmpty && !isAddingToBank;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text('คำศัพท์ที่ยังไม่รู้', style: AppTextStyles.subtitle),
            initiallyExpanded: false,
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                child: _buildWordsList(context, colorScheme),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: canAddToBank ? onAddToBank : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: isAddingToBank
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text('เพิ่มเข้าคลัง', style: AppTextStyles.buttonText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWordsList(BuildContext context, ColorScheme colorScheme) {
    if (unknownWords.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Text(
            'อย่าลืมหมั่นทบทวน!',
            style: AppTextStyles.body.copyWith(
              color: colorScheme.primary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    final uniqueWords = unknownWords.toSet().toList();

    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: uniqueWords.map((word) {
        final isSelected = selectedWords.contains(word);
        return FilterChip(
          label: Text(
            word,
            style: AppTextStyles.label.copyWith(
              color: isSelected ? Colors.white : colorScheme.primary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          selected: isSelected,
          onSelected: (_) => onToggleWord(word),
          selectedColor: colorScheme.primary,
          checkmarkColor: Colors.white,
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
                color: isSelected ? colorScheme.primary : colorScheme.outline),
          ),
        );
      }).toList(),
    );
  }
}
