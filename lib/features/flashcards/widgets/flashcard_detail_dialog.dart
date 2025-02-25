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
  Map<String, String> translations = {};

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
    await _translateDefinition();
    if (widget.flashcard.exampleSentence['sentence']?.isNotEmpty ?? false) {
      await _translateExample();
    }
  }

  Future<void> _translateDefinition() async {
    if (widget.flashcard.definition.isNotEmpty) {
      final translation = await translator.translate(
        widget.flashcard.definition,
        from: 'en',
        to: 'th',
      );
      translations['definition'] = translation.text;
    }
  }

  Future<void> _translateExample() async {
    if (widget.flashcard.exampleSentence['sentence']?.isNotEmpty ?? false) {
      final translation = await translator.translate(
        widget.flashcard.exampleSentence['sentence']!,
        from: 'en',
        to: 'th',
      );
      translations['example'] = translation.text;
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
    return (cefr == null || cefr.contains('›') || cefr == '>') ? 'N/A' : cefr;
  }

  // UI Building Methods
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

  Widget _buildSenseCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            _buildSenseInfo(),
            const SizedBox(height: 8),
            _buildDefinition(),
            if (widget.flashcard.exampleSentence['sentence']?.isNotEmpty ??
                false) ...[
              const SizedBox(height: 8),
              _buildExample(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            _formatText(widget.flashcard.hint, defaultText: 'General'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSenseInfo() {
    return Row(
      children: [
        if (widget.flashcard.partOfSpeech.isNotEmpty)
          Expanded(
            child: Text(
              widget.flashcard.partOfSpeech,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.blue,
              ),
            ),
          ),
        Text(
          'CEFR: ${_formatCEFR(widget.flashcard.cefrLevel)}',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDefinition() {
    return Text(
      isTranslated
          ? translations['definition'] ?? widget.flashcard.definition
          : widget.flashcard.definition,
      style: TextStyle(
        fontSize: 16,
        fontStyle: isTranslated ? FontStyle.italic : FontStyle.normal,
      ),
    );
  }

  Widget _buildExample() {
    final example = widget.flashcard.exampleSentence['sentence'] ?? '';
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
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Text(
            '• ${isTranslated ? translations['example'] ?? example : example}',
            style: const TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _buildDialogTitle(),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSenseCard(),
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
}
