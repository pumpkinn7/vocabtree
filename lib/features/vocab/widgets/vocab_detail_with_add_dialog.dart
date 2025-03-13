import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class VocabDetailWithAddDialog extends StatefulWidget {
  final String wordId;
  final Map<String, dynamic> vocabData;
  final String level;
  final String topic;
  final String userId;

  const VocabDetailWithAddDialog({
    super.key,
    required this.wordId,
    required this.vocabData,
    required this.level,
    required this.topic,
    required this.userId,
  });

  @override
  State<VocabDetailWithAddDialog> createState() =>
      _VocabDetailWithAddDialogState();
}

class _VocabDetailWithAddDialogState extends State<VocabDetailWithAddDialog> {
  final translator = GoogleTranslator();
  bool isTranslated = false;
  bool isLoading = false;
  Map<String, String> translations = {};
  List<Map<String, dynamic>> senses = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _setupBasicData();
    _loadExtendedData();
  }

  void _setupBasicData() {
    senses = [
      {
        'title': 'General',
        'usage': 'N/A',
        'partOfSpeech': widget.vocabData['type'] ?? '',
        'cefr': widget.vocabData['cefrLevel'] ?? widget.level,
        'definition':
            widget.vocabData['definition'] ?? widget.vocabData['meaning'] ?? '',
        'examples': widget.vocabData['example_sentence'] != null
            ? [widget.vocabData['example_sentence']]
            : [],
      }
    ];
  }

  Future<void> _loadExtendedData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('words')
          .doc(widget.wordId)
          .get();

      if (!doc.exists) return;

      final data = doc.data()!;
      final sensesData = data['senses'] as List?;

      if (sensesData != null && sensesData.isNotEmpty) {
        senses.clear();
        for (var sense in sensesData) {
          if (sense is Map<String, dynamic>) {
            String title = sense['title']?.toString() ?? 'General';
            String usage = sense['usage']?.toString() ?? 'N/A';

            senses.add({
              'title': title,
              'usage': usage,
              'partOfSpeech': sense['partOfSpeech'] ?? data['mainPos'] ?? '',
              'cefr': sense['cefr'] ?? widget.level,
              'definition': sense['definition'] ?? '',
              'examples': sense['examples'] ?? [],
            });
          }
        }
      }
    } catch (_) {
      // Silent error handling
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _toggleTranslation() async {
    if (isTranslated) {
      setState(() => isTranslated = false);
      return;
    }

    try {
      for (int i = 0; i < senses.length; i++) {
        final sense = senses[i];
        final definition = sense['definition']?.toString() ?? '';

        if (definition.isNotEmpty) {
          final defTranslation = await translator.translate(
            definition,
            from: 'en',
            to: 'th',
          );
          translations['def_$i'] = defTranslation.text;
        }

        final examples = (sense['examples'] as List?)?.cast<String>() ?? [];
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

      if (mounted) setState(() => isTranslated = true);
    } catch (_) {
      // Silent error handling
    }
  }

  Future<void> _addToReviewWords() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('vocabulary_progress')
          .doc(widget.topic)
          .set({
        'review_words': FieldValue.arrayUnion([widget.wordId])
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เพิ่มคำศัพท์เข้าคลังทบทวนแล้ว')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เกิดข้อผิดพลาดในการเพิ่มคำศัพท์')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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
      content: isLoading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < senses.length; i++)
                    _buildSenseCard(i, senses[i]),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: _addToReviewWords,
          style: TextButton.styleFrom(foregroundColor: Colors.green),
          child: Text(
            'เพิ่มคำศัพท์',
            style: AppTextStyles.buttonText,
          ),
        ),
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

  Widget _buildSenseCard(int index, Map<String, dynamic> sense) {
    final colorScheme = Theme.of(context).colorScheme;
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
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
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
