import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

import '../model/flashcard_topic_model.dart';

/// แสดงรายละเอียดของ Flashcard
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

  // ลบเมธอด _formatText และ _formatCEFR ที่ไม่ได้ใช้งาน

  // โหลดข้อมูล
  Future<void> _loadData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('words')
          .doc(widget.flashcard.id)
          .get();

      if (!mounted) return;

      // ถ้าไม่พบข้อมูลในฐานข้อมูล
      if (!doc.exists || doc.data() == null) {
        setState(() {
          // แน่ใจว่าใส่ค่า default ที่นี่
          senses = [
            {
              'title': 'General', // default title
              'usage': 'N/A', // default usage
              'partOfSpeech': widget.flashcard.partOfSpeech,
              'cefr': widget.flashcard.cefrLevel,
              'definition': widget.flashcard.definition.isNotEmpty
                  ? widget.flashcard.definition
                  : 'No definition available',
              'examples': [],
            }
          ];
          isLoading = false;
        });
        return;
      }

      final data = doc.data()!;
      final List<Map<String, dynamic>> loadedSenses = [];

      // ดึงข้อมูลจาก senses
      if (data['senses'] is List && (data['senses'] as List).isNotEmpty) {
        for (var sense in data['senses']) {
          if (sense is Map<String, dynamic>) {
            // กำหนดค่า default ที่นี่
            loadedSenses.add({
              'title':
                  sense['title'] == null || sense['title'].toString().isEmpty
                      ? 'General'
                      : sense['title'],
              'usage':
                  sense['usage'] == null || sense['usage'].toString().isEmpty
                      ? 'N/A'
                      : sense['usage'],
              'partOfSpeech': sense['partOfSpeech'] ?? data['mainPos'] ?? '',
              'cefr': sense['cefr'] ?? widget.flashcard.cefrLevel,
              'definition': sense['definition'] ?? '',
              'examples': sense['examples'] ?? [],
            });
          }
        }
      }

      // ถ้าไม่มี senses ใช้ข้อมูลจาก flashcard
      if (loadedSenses.isEmpty) {
        loadedSenses.add({
          'title': 'General', // กำหนดค่า default แบบชัดเจน
          'usage': 'N/A', // กำหนดค่า default แบบชัดเจน
          'partOfSpeech': widget.flashcard.partOfSpeech,
          'cefr': widget.flashcard.cefrLevel,
          'definition': widget.flashcard.definition,
          'examples': [],
        });
      }

      setState(() {
        senses = loadedSenses;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          // แน่ใจว่าใส่ค่า default ที่นี่ด้วย
          senses = [
            {
              'title': 'General', // ใส่ string ตรงๆ
              'usage': 'N/A', // ใส่ string ตรงๆ
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

  // แปลภาษา
  Future<void> _toggleTranslation() async {
    if (isTranslated) {
      setState(() => isTranslated = false);
      return;
    }

    try {
      // แปลคำจำกัดความและตัวอย่างประโยค
      for (int i = 0; i < senses.length; i++) {
        final sense = senses[i];

        // แปลคำจำกัดความ
        if (sense['definition'] != null &&
            sense['definition'].toString().isNotEmpty) {
          final translation = await translator.translate(
            sense['definition'],
            from: 'en',
            to: 'th',
          );
          translations['def_$i'] = translation.text;
        }

        // แปลตัวอย่างประโยค
        if (sense['examples'] != null) {
          final examples = List<String>.from(sense['examples']);
          for (int j = 0; j < examples.length; j++) {
            if (examples[j].isNotEmpty) {
              final translation = await translator.translate(
                examples[j],
                from: 'en',
                to: 'th',
              );
              translations['example_${i}_$j'] = translation.text;
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
    if (isLoading) {
      return const AlertDialog(
        content: SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

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
          children: [
            ...senses.asMap().entries.map((entry) {
              final index = entry.key;
              final sense = entry.value;
              return _buildSenseCard(index, sense);
            }),
          ],
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

  // สร้างการ์ดแสดงความหมาย
  Widget _buildSenseCard(int index, Map<String, dynamic> sense) {
    // เพิ่ม print เพื่อตรวจสอบค่าที่ได้รับ
    debugPrint('Sense data: title=${sense['title']}, usage=${sense['usage']}');

    // กำหนดค่า default ใหม่ และตรวจสอบว่า sense['title'] และ sense['usage'] มีค่าเป็น null หรือ empty string
    final String title =
        (sense['title'] == null || sense['title'].toString().isEmpty)
            ? 'General'
            : sense['title'].toString();

    final String usage =
        (sense['usage'] == null || sense['usage'].toString().isEmpty)
            ? 'N/A'
            : sense['usage'].toString();

    // อื่นๆ คงเดิม
    final String partOfSpeech = sense['partOfSpeech'] ?? '';
    final String cefr =
        sense['cefr'] == null || sense['cefr'].toString().contains('›')
            ? 'N/A'
            : sense['cefr'].toString();
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
                // แก้ไขการแสดงผล title
                Expanded(
                  child: Text(
                    title, // ควรเป็น "General" ถ้าไม่มีข้อมูล
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // แก้ไขการแสดงผล usage
                Text(
                  usage, // ควรเป็น "N/A" ถ้าไม่มีข้อมูล
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

            // ชนิดคำและระดับ CEFR - แสดงเสมอ
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
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),

            // คำจำกัดความ - แสดงเสมอ
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

            // ตัวอย่างประโยค - แสดงเฉพาะเมื่อมีข้อมูล
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
                final int exampleIndex = e.key;
                final String example = e.value;
                final String translatedExample =
                    translations['example_${index}_$exampleIndex'] ?? example;

                return Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 4),
                  child: Text(
                    '• ${isTranslated ? translatedExample : example}',
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
