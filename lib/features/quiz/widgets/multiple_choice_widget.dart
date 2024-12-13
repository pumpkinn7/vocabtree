import 'package:flutter/material.dart';

import '../model/quiz_question_model.dart';

class MultipleChoiceWidget extends StatelessWidget {
  final QuizQuestionModel question;
  final String? selectedOption;
  final ValueChanged<String?> onOptionSelected;
  final bool isAnswerChecked;
  final bool isCorrect;

  const MultipleChoiceWidget({
    super.key,
    required this.question,
    required this.selectedOption,
    required this.onOptionSelected,
    required this.isAnswerChecked,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    final q = question;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          q.question,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...q.options.map((option) {
          Color? optionColor;
          if (isAnswerChecked) {
            if (option == q.correctAnswer) {
              optionColor = Colors.green[200];
            } else if (option == selectedOption && option != q.correctAnswer) {
              optionColor = Colors.red[200];
            }
          }
          return RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: selectedOption,
            onChanged: isAnswerChecked
                ? null
                : (val) {
              onOptionSelected(val);
            },
            tileColor: optionColor,
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
        // แสดงผลลัพธ์หลังการตรวจสอบ
        if (isAnswerChecked)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              isCorrect ? 'ถูกต้อง!' : 'ตอบผิด!',
              style: TextStyle(
                color: isCorrect ? Colors.green : Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}
