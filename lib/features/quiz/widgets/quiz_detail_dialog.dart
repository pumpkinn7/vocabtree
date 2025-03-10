import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class QuizDetailDialog extends StatefulWidget {
  final List<Map<String, dynamic>> senses;

  const QuizDetailDialog({super.key, required this.senses});

  @override
  State<QuizDetailDialog> createState() => _QuizDetailDialogState();
}

class _QuizDetailDialogState extends State<QuizDetailDialog> {
  final translator = GoogleTranslator();
  bool isTranslated = false;
  Map<String, String> translations = {};

  // แปลภาษาแบบกระชับ
  Future<void> _toggleTranslation() async {
    if (isTranslated) {
      setState(() => isTranslated = false);
      return;
    }

    try {
      for (int i = 0; i < widget.senses.length; i++) {
        final sense = widget.senses[i];

        // แปลคำจำกัดความ
        if (sense['definition']?.toString().isNotEmpty == true) {
          final defTranslation = await translator.translate(
            sense['definition'],
            from: 'en',
            to: 'th',
          );
          translations['def_$i'] = defTranslation.text;
        }

        // แปลตัวอย่างประโยค
        if (sense['examples'] is List) {
          final examples = List<String>.from(sense['examples']);
          for (int j = 0; j < examples.length; j++) {
            if (examples[j].isNotEmpty) {
              final exTranslation = await translator.translate(
                examples[j],
                from: 'en',
                to: 'th',
              );
              translations['example_${i}_$j'] = exTranslation.text;
            }
          }
        }
      }

      if (mounted) setState(() => isTranslated = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ไม่สามารถแปลภาษาได้: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      title: Row(
        children: [
          Expanded(
            child: Text(
              "ความหมายทั้งหมด",
              style: AppTextStyles.subtitle,
            ),
          ),
          IconButton(
            icon: Icon(
              isTranslated ? Icons.g_translate_outlined : Icons.translate,
              color: colorScheme.primary,
            ),
            onPressed: _toggleTranslation,
            tooltip: isTranslated ? 'แสดงภาษาอังกฤษ' : 'แปลเป็นภาษาไทย',
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.senses
              .asMap()
              .entries
              .map((entry) =>
                  _buildSenseCard(entry.key, entry.value, colorScheme))
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'ปิด',
            style: AppTextStyles.buttonText.copyWith(
              color: colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  // สร้างการ์ดแสดงความหมายแบบกระชับ
  Widget _buildSenseCard(
      int index, Map<String, dynamic> sense, ColorScheme colorScheme) {
    // กำหนดค่าที่ใช้แสดงผล
    final String title = sense['title']?.toString().isNotEmpty == true
        ? sense['title'].toString()
        : 'General';
    final String usage = sense['usage']?.toString().isNotEmpty == true
        ? sense['usage'].toString()
        : 'N/A';
    final String partOfSpeech = sense['partOfSpeech'] ?? '';
    final String cefr = sense['cefr']?.toString().contains('›') == true
        ? 'N/A'
        : (sense['cefr']?.toString() ?? 'N/A');
    final String definition = sense['definition'] ?? '';
    final List<String> examples =
        sense['examples'] is List ? List<String>.from(sense['examples']) : [];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: colorScheme.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // หัวข้อและการใช้
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.subtitle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  usage,
                  style: AppTextStyles.caption.copyWith(
                    fontStyle: FontStyle.italic,
                    color: usage == 'N/A'
                        ? colorScheme.outline.withOpacity(0.6)
                        : colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ชนิดคำและระดับ CEFR
            Row(
              children: [
                Expanded(
                  child: Text(
                    partOfSpeech,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                Text(
                  'CEFR: $cefr',
                  style: AppTextStyles.caption.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ],
            ),

            // คำจำกัดความ
            if (definition.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                isTranslated
                    ? (translations['def_$index'] ?? definition)
                    : definition,
                style: AppTextStyles.body.copyWith(
                  fontStyle: isTranslated ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ],

            // ตัวอย่างประโยค (แสดงเฉพาะเมื่อมีข้อมูล)
            if (examples.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Examples:',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              ...examples.asMap().entries.map((e) {
                final translatedExample =
                    translations['example_${index}_${e.key}'] ?? e.value;
                return Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 4),
                  child: Text(
                    '• ${isTranslated ? translatedExample : e.value}',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
