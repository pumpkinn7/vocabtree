import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import '../models/quiz_question_model.dart';
import '../widgets/quiz_detail_dialog.dart';

class MultipleChoiceWidget extends StatelessWidget {
  final QuizQuestionModel question;
  final String? selectedOption;
  final Function(String) onOptionSelected;
  final bool isAnswerChecked;
  final bool isCorrect;
  final bool isFrequentlyWrong;
  final int wrongCount;

  const MultipleChoiceWidget({
    super.key,
    required this.question,
    required this.selectedOption,
    required this.onOptionSelected,
    required this.isAnswerChecked,
    required this.isCorrect,
    required this.isFrequentlyWrong,
    required this.wrongCount,
  });

  String _formatCEFR(String? cefr) {
    if (cefr == null || cefr.contains('›')) {
      return 'N/A';
    }
    return cefr;
  }

  @override
  Widget build(BuildContext context) {
    return BootstrapContainer(
      fluid: true,
      padding: EdgeInsets.zero,
      children: [
        BootstrapRow(
          children: [
            BootstrapCol(
              sizes: 'col-xs-12 col-sm-12 col-md-10 col-lg-8 col-xl-6',
              offsets:
                  'offset-xs-0 offset-sm-0 offset-md-1 offset-lg-2 offset-xl-3',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // แสดงส่วนคำเตือนสำหรับคำที่ตอบผิดบ่อย
                  if (isFrequentlyWrong) _buildFrequentlyWrongWarning(context),

                  // แสดงระดับ CEFR
                  _buildCefrLevel(),

                  const SizedBox(height: 16),

                  // แสดงคำถาม/คำอธิบาย
                  _buildDefinition(),

                  const SizedBox(height: 8),

                  // ปุ่มดูรายละเอียดเพิ่มเติม
                  _buildDetailsButton(context),

                  const SizedBox(height: 24),

                  // แสดงตัวเลือก Duolingo style (grid layout)
                  _buildOptionsGrid(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFrequentlyWrongWarning(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
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
    );
  }

  Widget _buildCefrLevel() {
    return Text(
      'CEFR Level: ${_formatCEFR(question.senses.isNotEmpty ? question.senses[0]['cefr'] : null)}',
      style: AppTextStyles.subtitle
          .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDefinition() {
    return Text(
      question.definition,
      style: AppTextStyles.body.copyWith(fontSize: 18),
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
      child: Text(
        'ดูรายละเอียดเพิ่มเติม',
        style: AppTextStyles.buttonText.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildOptionsGrid() {
    return BootstrapContainer(
      fluid: true,
      padding: EdgeInsets.zero,
      children: [
        BootstrapRow(
          children: _buildOptionPairs(),
        ),
      ],
    );
  }

  List<BootstrapCol> _buildOptionPairs() {
    final List<BootstrapCol> optionPairs = [];

    for (int i = 0; i < question.options.length; i++) {
      final option = question.options[i];
      optionPairs.add(
        BootstrapCol(
          sizes: 'col-xs-6 col-sm-6 col-md-6 col-lg-6 col-xl-6',
          child: _buildOptionTile(option),
        ),
      );
    }

    return optionPairs;
  }

  Widget _buildOptionTile(String option) {
    final bool isSelected = selectedOption == option;
    final bool isCorrectOption = question.mainWord == option;
    final bool showResult = isAnswerChecked;

    // กำหนดสีตามสถานะ
    Color? backgroundColor;
    Color? textColor;
    Color borderColor = Colors.grey.shade300;
    IconData? trailingIcon;

    if (showResult) {
      if (isCorrectOption) {
        backgroundColor = Colors.green.shade100;
        borderColor = Colors.green;
        textColor = Colors.green.shade900;
        trailingIcon = Icons.check_circle;
      } else if (isSelected && !isCorrectOption) {
        backgroundColor = Colors.red.shade100;
        borderColor = Colors.red;
        textColor = Colors.red.shade900;
        trailingIcon = Icons.cancel;
      }
    } else if (isSelected) {
      backgroundColor = Colors.blue.shade100;
      borderColor = Colors.blue;
      textColor = Colors.blue.shade900;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 6, left: 6),
      child: InkWell(
        onTap: isAnswerChecked ? null : () => onOptionSelected(option),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Radio<String>(
                value: option,
                groupValue: selectedOption,
                onChanged: isAnswerChecked
                    ? null
                    : (value) => value != null ? onOptionSelected(value) : null,
                activeColor: textColor ?? Colors.blue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  option,
                  style: AppTextStyles.body.copyWith(
                    color: textColor,
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
                ),
              ),
              if (trailingIcon != null)
                Icon(
                  trailingIcon,
                  color: textColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
