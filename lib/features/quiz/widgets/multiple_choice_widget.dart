import 'package:flutter/material.dart';

import '../model/quiz_question_model.dart';

class MultipleChoiceWidget extends StatefulWidget {
  final QuizQuestionModel question;
  final ValueChanged<bool> onAnswered;

  const MultipleChoiceWidget({
    super.key,
    required this.question,
    required this.onAnswered,
  });

  @override
  State<MultipleChoiceWidget> createState() => _MultipleChoiceWidgetState();
}

class _MultipleChoiceWidgetState extends State<MultipleChoiceWidget> {
  String? _selectedOption;

  @override
  Widget build(BuildContext context) {
    final q = widget.question;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          q.question,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...q.options.map((option) {
          return RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: _selectedOption,
            onChanged: (val) {
              setState(() {
                _selectedOption = val;
              });
              // เมื่อผู้ใช้เลือกคำตอบ ตรวจสอบความถูกต้อง
              final correct = (val == q.correctAnswer);
              // เรียก callback บอกไปว่าตอบถูกหรือผิด
              widget.onAnswered(correct);
            },
          );
        }),
        const SizedBox(height: 16),
        if (q.partOfSpeech.isNotEmpty)
          Text('Part of Speech: ${q.partOfSpeech}', style: const TextStyle(fontSize: 16)),
        if (q.exampleSentence.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text('Example: ${q.exampleSentence}', style: const TextStyle(fontSize: 16)),
          ),
        if (q.translatedSentence.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text('แปล: ${q.translatedSentence}', style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
          ),
      ],
    );
  }
}
