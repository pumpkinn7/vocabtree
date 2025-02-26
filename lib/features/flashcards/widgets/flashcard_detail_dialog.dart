import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

import '../model/flashcard_topic_model.dart';

class FlashcardDetailDialog extends StatefulWidget {
  final Flashcard flashcard;
  const FlashcardDetailDialog({super.key, required this.flashcard});

  @override
  State<FlashcardDetailDialog> createState() => _FlashcardDetailDialogState();
}

class _FlashcardDetailDialogState extends State<FlashcardDetailDialog> {
  final translator = GoogleTranslator();
  bool isTranslated = false;
  bool isLoading = true;
  Map<String, String> translations = {};
  List<Map<String, dynamic>> senses = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // โหลดข้อมูลและจัดการกรณีต่างๆ แบบกระชับ
  Future<void> _loadData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('words')
          .doc(widget.flashcard.id)
          .get();

      final List<Map<String, dynamic>> loadedSenses = [];

      // กรณีมีข้อมูล senses
      if (doc.exists && doc.data() != null && doc.data()!['senses'] is List) {
        final sensesData = doc.data()!['senses'] as List;
        final data = doc.data()!;

        for (var sense in sensesData) {
          if (sense is Map<String, dynamic>) {
            loadedSenses.add({
              'title': sense['title']?.toString().isNotEmpty == true
                  ? sense['title']
                  : 'General',
              'usage': sense['usage']?.toString().isNotEmpty == true
                  ? sense['usage']
                  : 'N/A',
              'partOfSpeech': sense['partOfSpeech'] ?? data['mainPos'] ?? '',
              'cefr': sense['cefr'] ?? widget.flashcard.cefrLevel,
              'definition': sense['definition'] ?? '',
              'examples': sense['examples'] ?? [],
            });
          }
        }
      }

      // ถ้าไม่มีข้อมูลหรือ senses ว่าง ให้ใช้ข้อมูลจาก flashcard
      if (loadedSenses.isEmpty) {
        loadedSenses.add({
          'title': 'General',
          'usage': 'N/A',
          'partOfSpeech': widget.flashcard.partOfSpeech,
          'cefr': widget.flashcard.cefrLevel,
          'definition': widget.flashcard.definition,
          'examples': [],
        });
      }

      if (mounted) {
        setState(() {
          senses = loadedSenses;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          senses = [
            {
              'title': 'General',
              'usage': 'N/A',
              'partOfSpeech': widget.flashcard.partOfSpeech,
              'cefr': widget.flashcard.cefrLevel,
              'definition': widget.flashcard.definition,
              'examples': [],
            }
          ];
          isLoading = false;
        });
      }
    }
  }

  // แปลภาษาแบบกระชับ
  Future<void> _toggleTranslation() async {
    if (isTranslated) {
      setState(() => isTranslated = false);
      return;
    }

    try {
      for (int i = 0; i < senses.length; i++) {
        final sense = senses[i];

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
          SnackBar(content: Text('ไม่สามารถแปลภาษาได้: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // แสดง loading
    if (isLoading) {
      return const AlertDialog(
        content: SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // แสดงข้อความว่างถ้าไม่มีข้อมูล
    if (senses.isEmpty) {
      return AlertDialog(
        title: const Text('ข้อผิดพลาด'),
        content: const Text('ไม่พบข้อมูลคำศัพท์'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: Row(
        children: [
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
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: senses
              .asMap()
              .entries
              .map((entry) => _buildSenseCard(entry.key, entry.value))
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ปิด'),
        ),
      ],
    );
  }

  // สร้างการ์ดแสดงความหมายแบบกระชับ
  Widget _buildSenseCard(int index, Map<String, dynamic> sense) {
    // กำหนดค่าที่ใช้แสดงผล
    final String title = sense['title'] ?? 'General';
    final String usage = sense['usage'] ?? 'N/A';
    final String partOfSpeech = sense['partOfSpeech'] ?? '';
    final String cefr = sense['cefr']?.toString().contains('›') == true
        ? 'N/A'
        : (sense['cefr']?.toString() ?? 'N/A');
    final String definition = sense['definition'] ?? '';
    final List<String> examples =
        sense['examples'] is List ? List<String>.from(sense['examples']) : [];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                    color: usage == 'N/A'
                        ? Colors.grey.withOpacity(0.6)
                        : Colors.grey,
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

            // คำจำกัดความ
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

            // ตัวอย่างประโยค (แสดงเฉพาะเมื่อมีข้อมูล)
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
              ...examples.asMap().entries.map((e) {
                final translatedExample =
                    translations['example_${index}_${e.key}'] ?? e.value;
                return Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 4),
                  child: Text(
                    '• ${isTranslated ? translatedExample : e.value}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
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
