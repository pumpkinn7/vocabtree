import 'package:flutter/material.dart';

import '../model/quiz_question_model.dart';

class MultipleChoiceWidget extends StatelessWidget {
  final QuizQuestionModel question;
  final String? selectedOption;
  final Function(String) onOptionSelected;
  final bool isAnswerChecked;
  final bool isCorrect;

  const MultipleChoiceWidget({
    super.key,
    required this.question,
    this.selectedOption,
    required this.onOptionSelected,
    required this.isAnswerChecked,
    required this.isCorrect,
  });

  String _formatCEFR(String? cefr) {
    return (cefr == null || cefr.contains('›')) ? 'N/A' : cefr;
  }

  String _formatText(String? text, {String defaultText = 'N/A'}) {
    return (text?.isEmpty ?? true) ? defaultText : text!;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CEFR Level from first sense
        Text(
          'CEFR Level: ${_formatCEFR(question.senses.isNotEmpty ? question.senses[0]['cefr'] : null)}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Definition
        Text(
          question.definition,
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 8),

        // Details button
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("All Meanings"),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: question.senses
                        .map((sense) => Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title and Usage in header
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _formatText(sense['title'],
                                                defaultText: 'General'),
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
                                    ),
                                    const SizedBox(height: 8),

                                    // Part of Speech and CEFR Level
                                    Row(
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
                                    ),
                                    const Divider(height: 16),

                                    // Definition
                                    if (sense['definition'] != null) ...[
                                      Text(
                                        sense['definition'],
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(height: 8),
                                    ],

                                    // Examples
                                    if (sense['examples'] != null &&
                                        (sense['examples'] as List)
                                            .isNotEmpty) ...[
                                      const Text(
                                        'Examples:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      ...List<String>.from(sense['examples'])
                                          .map(
                                        (e) => Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8,
                                            bottom: 4,
                                          ),
                                          child: Text(
                                            '• $e',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontStyle: FontStyle.italic,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ปิด'),
                  ),
                ],
              ),
            );
          },
          child: const Text('ดูรายละเอียดเพิ่มเติม'),
        ),
        const SizedBox(height: 16),

        // แสดงตัวเลือก
        ...question.options.map((option) => ListTile(
              title: Text(option),
              leading: Radio<String>(
                value: option,
                groupValue: selectedOption,
                onChanged: isAnswerChecked
                    ? null
                    : (value) {
                        if (value != null) onOptionSelected(value);
                      },
              ),
              tileColor: isAnswerChecked
                  ? (option == question.mainWord
                      ? Colors.green.withOpacity(0.2)
                      : (option == selectedOption
                          ? Colors.red.withOpacity(0.2)
                          : null))
                  : null,
            )),
      ],
    );
  }
}
