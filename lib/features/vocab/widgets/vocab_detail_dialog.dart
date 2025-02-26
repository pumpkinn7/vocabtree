import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class VocabDetailDialog extends StatefulWidget {
  final String wordId;
  final Map<String, dynamic> vocabData;
  final String level;
  final String topic;
  final String userId;
  final Function(String) onRemoveWord;

  const VocabDetailDialog({
    super.key,
    required this.wordId,
    required this.vocabData,
    required this.level,
    required this.topic,
    required this.userId,
    required this.onRemoveWord,
  });

  @override
  State<VocabDetailDialog> createState() => _VocabDetailDialogState();
}

class _VocabDetailDialogState extends State<VocabDetailDialog> {
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
        'title': 'General', // เปลี่ยนเป็น 'General' ทุกครั้ง
        'usage': 'N/A', // เปลี่ยนเป็น 'N/A' ทุกครั้ง
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

      if (!mounted || !doc.exists || doc.data() == null) return;

      final sensesData = doc.data()!['senses'] as List?;
      if (sensesData == null || sensesData.isEmpty) return;

      final data = doc.data()!;
      final List<Map<String, dynamic>> loadedSenses = [];

      for (var sense in sensesData) {
        if (sense is Map<String, dynamic>) {
          // กำหนดค่าเริ่มต้นชัดเจน
          String title = 'General';
          String usage = 'N/A';

          // ตรวจสอบแล้วใช้ค่าที่มีถ้าไม่ว่าง
          if (sense['title']?.toString().isNotEmpty == true) {
            title = sense['title'];
          }

          if (sense['usage']?.toString().isNotEmpty == true) {
            usage = sense['usage'];
          }

          loadedSenses.add({
            'title': title,
            'usage': usage,
            'partOfSpeech': sense['partOfSpeech'] ?? data['mainPos'] ?? '',
            'cefr': sense['cefr'] ?? widget.level,
            'definition': sense['definition'] ?? '',
            'examples': sense['examples'] ?? [],
          });
        }
      }

      if (loadedSenses.isNotEmpty && mounted) {
        setState(() => senses = loadedSenses);
      }
    } catch (_) {
      // ไม่ต้องทำอะไรเมื่อเกิด error เพราะเรามีข้อมูลพื้นฐานอยู่แล้ว
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
      // ไม่แสดงข้อผิดพลาดในการแปล
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          // เปลี่ยนจากชื่อคำศัพท์เป็น "All Meanings"
          const Expanded(child: Text("All Meanings")),
          IconButton(
            icon: Icon(
              isTranslated ? Icons.g_translate_outlined : Icons.translate,
              color: Colors.blue,
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
          onPressed: () {
            widget.onRemoveWord(widget.wordId);
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(foregroundColor: Colors.orange),
          child: const Text('ลบคำศัพท์'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ปิด'),
        ),
      ],
    );
  }

  Widget _buildSenseCard(int index, Map<String, dynamic> sense) {
    // กำหนดค่าเริ่มต้นสำหรับ title และ usage เพื่อให้แน่ใจว่าการตรวจสอบทำงานถูกต้อง
    final String title = sense['title'] ?? 'General';
    final String usage = sense['usage'] ?? 'N/A';
    final String partOfSpeech = sense['partOfSpeech'] ?? '';
    final String cefr = sense['cefr']?.toString() ?? 'N/A';
    final String definition = sense['definition'] ?? '';
    final List<String> examples =
        (sense['examples'] as List?)?.cast<String>() ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  usage,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    // แก้ไขการตรวจสอบให้ถูกต้อง
                    color: usage == 'N/A'
                        ? Colors.grey.withOpacity(0.6)
                        : Colors.grey,
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
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                ),
                Text(
                  'CEFR: $cefr',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isTranslated
                  ? (translations['def_$index'] ?? definition)
                  : definition,
              style: TextStyle(
                fontSize: 16,
                fontStyle: isTranslated ? FontStyle.italic : FontStyle.normal,
              ),
            ),
            if (examples.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Examples:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              for (int j = 0; j < examples.length; j++)
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 4),
                  child: Text(
                    '• ${isTranslated ? (translations['example_${index}_$j'] ?? examples[j]) : examples[j]}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
