import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

import '../model/flashcard_topic_model.dart';

/// แสดงรายละเอียดของ Flashcard (คัดลอกจาก QuizDetailDialog 100%)
class FlashcardDetailDialog extends StatefulWidget {
  final Flashcard flashcard;

  const FlashcardDetailDialog({
    super.key,
    required this.flashcard,
  });

  @override
  State<FlashcardDetailDialog> createState() => _FlashcardDetailDialogState();
}

class _FlashcardDetailDialogState extends State<FlashcardDetailDialog> {
  final translator = GoogleTranslator();
  bool isTranslated = false;
  Map<String, String> translations = {};
  List<Map<String, dynamic>> senses = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _loadWordSenses();
  }

  Future<void> _loadWordSenses() async {
    try {
      final loadedSenses = await _getWordSenses(widget.flashcard.id);
      setState(() {
        senses = loadedSenses;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      debugPrint('Error loading word senses: $e');
    }
  }

  // Translation Methods
  Future<void> _toggleTranslation() async {
    if (isTranslated) {
      setState(() => isTranslated = false);
      return;
    }

    try {
      await _translateAllContent();
      if (mounted) setState(() => isTranslated = true);
    } catch (e) {
      if (mounted) _showTranslationError(e.toString());
    }
  }

  Future<void> _translateAllContent() async {
    await Future.wait(
      senses.asMap().entries.map((entry) async {
        final index = entry.key;
        final sense = entry.value;

        await Future.wait([
          _translateDefinition(sense, index),
          _translateExamples(sense, index),
        ]);
      }),
    );
  }

  Future<void> _translateDefinition(
      Map<String, dynamic> sense, int index) async {
    if (sense['definition'] != null) {
      final translation = await translator.translate(
        sense['definition'],
        from: 'en',
        to: 'th',
      );
      translations['def_$index'] = translation.text;
    }
  }

  Future<void> _translateExamples(Map<String, dynamic> sense, int index) async {
    if (sense['examples'] != null) {
      final examples = List<String>.from(sense['examples']);
      for (int i = 0; i < examples.length; i++) {
        final translation = await translator.translate(
          examples[i],
          from: 'en',
          to: 'th',
        );
        translations['example_${index}_$i'] = translation.text;
      }
    }
  }

  void _showTranslationError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ไม่สามารถแปลภาษาได้: $error'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Helper Methods
  String _formatText(String? text, {String defaultText = 'N/A'}) {
    return (text?.isEmpty ?? true) ? defaultText : text!;
  }

  String _formatCEFR(String? cefr) {
    return (cefr == null || cefr.contains('›')) ? 'N/A' : cefr;
  }

  // UI Building Methods
  Widget _buildHeader(Map<String, dynamic> sense, int index) {
    return Row(
      children: [
        Expanded(
          child: Text(
            _formatText(sense['title'], defaultText: 'General'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          _formatText(sense['usage']),
          style: const TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDialogTitle() {
    return Row(
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
    );
  }

  Widget _buildSenseCard(int index, Map<String, dynamic> sense) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(sense, index),
            const SizedBox(height: 8),
            _buildSenseInfo(sense),
            if (sense['definition'] != null) ...[
              _buildDefinition(sense, index),
              const SizedBox(height: 8),
            ],
            if (sense['examples'] != null) _buildExamples(sense, index),
          ],
        ),
      ),
    );
  }

  Widget _buildSenseInfo(Map<String, dynamic> sense) {
    return Row(
      children: [
        if (sense['partOfSpeech'] != null)
          Expanded(
            child: Text(
              sense['partOfSpeech'],
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.blue,
              ),
            ),
          ),
        Text(
          'CEFR: ${_formatCEFR(sense['cefr'])}',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDefinition(Map<String, dynamic> sense, int index) {
    return Text(
      isTranslated
          ? translations['def_$index'] ?? sense['definition']
          : sense['definition'],
      style: TextStyle(
        fontSize: 16,
        fontStyle: isTranslated ? FontStyle.italic : FontStyle.normal,
      ),
    );
  }

  Widget _buildExamples(Map<String, dynamic> sense, int index) {
    final examples = List<String>.from(sense['examples']);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Examples:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        ...examples.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: Text(
                  '• ${isTranslated ? translations['example_${index}_${e.key}'] ?? e.value : e.value}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const AlertDialog(
        content: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (hasError || senses.isEmpty) {
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
      title: _buildDialogTitle(),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...senses.asMap().entries.map((entry) {
              return _buildSenseCard(entry.key, entry.value);
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

  /// ดึงข้อมูลความหมายของคำศัพท์จาก Firestore
  Future<List<Map<String, dynamic>>> _getWordSenses(String wordId) async {
    try {
      // ดึงข้อมูลจาก Firestore
      final doc = await FirebaseFirestore.instance
          .collection('words')
          .doc(wordId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return [];
      }

      final data = doc.data()!;
      final List<Map<String, dynamic>> senses = [];

      // ถ้ามี senses field ใน document
      if (data['senses'] != null && data['senses'] is List) {
        final sensesData = data['senses'] as List;

        for (var sense in sensesData) {
          if (sense is Map<String, dynamic>) {
            senses.add({
              'title': sense['title'] ?? 'General',
              'usage': sense['usage'] ?? '',
              'partOfSpeech': sense['partOfSpeech'] ?? data['mainPos'] ?? '',
              'cefr': sense['cefr'] ?? widget.flashcard.cefrLevel,
              'definition': sense['definition'] ?? '',
              'examples': sense['examples'] ?? [],
            });
          }
        }
      }

      // ถ้าไม่มี senses หรือ senses ว่างเปล่า ให้สร้างข้อมูลจาก flashcard
      if (senses.isEmpty) {
        senses.add({
          'title': 'Primary meaning',
          'usage': '',
          'partOfSpeech': widget.flashcard.partOfSpeech,
          'cefr': widget.flashcard.cefrLevel,
          'definition': widget.flashcard.definition,
          'examples': [], // ไม่มีตัวอย่างจาก Flashcard
        });
      }

      return senses;
    } catch (e) {
      debugPrint('Error fetching word senses: $e');
      return [];
    }
  }
}
