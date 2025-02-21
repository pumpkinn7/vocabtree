import 'package:flutter/material.dart';

import '../model/quiz_question_model.dart';
import 'quiz_detail_dialog.dart';

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCefrLevel(),
        const SizedBox(height: 16),
        _buildDefinition(),
        const SizedBox(height: 8),
        _buildDetailsButton(context),
        const SizedBox(height: 16),
        ..._buildOptions(),
      ],
    );
  }

  Widget _buildCefrLevel() {
    return Text(
      'CEFR Level: ${_formatCEFR(question.senses.isNotEmpty ? question.senses[0]['cefr'] : null)}',
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDefinition() {
    return Text(
      question.definition,
      style: const TextStyle(fontSize: 18),
    );
  }

  Widget _buildDetailsButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => QuizDetailDialog(senses: question.senses),
        );
      },
      child: const Text('ดูรายละเอียดเพิ่มเติม'),
    );
  }

  List<Widget> _buildOptions() {
    return question.options
        .map((option) => ListTile(
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
            ))
        .toList();
  }
}
