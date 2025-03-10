import 'package:flutter/material.dart';

import '../models/quiz_question_model.dart';
import 'quiz_detail_dialog.dart';

class MultipleChoiceWidget extends StatelessWidget {
  final QuizQuestionModel question;
  final String? selectedOption;
  final Function(String) onOptionSelected;
  final bool isAnswerChecked;
  final bool isCorrect;
  final bool isFrequentlyWrong; // Add this
  final int wrongCount; // เพิ่ม property ใหม่

  const MultipleChoiceWidget({
    super.key,
    required this.question,
    this.selectedOption,
    required this.onOptionSelected,
    required this.isAnswerChecked,
    required this.isCorrect,
    this.isFrequentlyWrong = false, // Add this
    this.wrongCount = 0, // เพิ่ม parameter ใหม่
  });

  String _formatCEFR(String? cefr) {
    // ถ้า cefr เป็น null หรือมีเครื่องหมาย › หรือเป็นค่าว่าง ให้แสดง N/A
    return (cefr == null || cefr.isEmpty || cefr.contains('›')) ? 'N/A' : cefr;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                question.thaiWord,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            if (isFrequentlyWrong) // แสดงเฉพาะคำที่ตอบผิดบ่อย
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[700]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "🔔", // เพิ่มไอคอนกระดิ่งเตือน
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.orange[700], size: 20),
                    const SizedBox(width: 4),
                    Text(
                      'ตอบผิด $wrongCount ครั้ง',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
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
