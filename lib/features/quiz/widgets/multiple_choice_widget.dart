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

  String _formatCEFR(String? cefr) =>
      (cefr == null || cefr.contains('›')) ? 'N/A' : cefr;

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
                  Text(
                    'CEFR Level: ${_formatCEFR(question.senses.isNotEmpty ? question.senses[0]['cefr'] : null)}',
                    style: AppTextStyles.subtitle
                        .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),

                  // แสดงคำถาม/คำอธิบาย
                  Text(
                    question.definition,
                    style: AppTextStyles.body.copyWith(fontSize: 18),
                  ),

                  const SizedBox(height: 8),

                  // ปุ่มดูรายละเอียดเพิ่มเติม
                  TextButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) =>
                          QuizDetailDialog(senses: question.senses),
                    ),
                    child: Text(
                      'ดูรายละเอียดเพิ่มเติม',
                      style: AppTextStyles.buttonText.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // แสดงตัวเลือก
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
        color: Colors.orange.withOpacity(0.1), // ทำให้พื้นหลังมี opacity ต่ำ
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("🔔", style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            'ตอบผิด $wrongCount ครั้ง',
            style: AppTextStyles.body.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsGrid() {
    return BootstrapRow(
      children: question.options
          .map((option) => BootstrapCol(
                sizes: 'col-xs-6 col-sm-6 col-md-6 col-lg-6 col-xl-6',
                child: _buildOptionTile(option),
              ))
          .toList(),
    );
  }

  Widget _buildOptionTile(String option) {
    // ส่ง context เข้ามาเป็นพารามิเตอร์
    return Builder(builder: (context) {
      final bool isSelected = selectedOption == option;
      final bool isCorrectOption = question.mainWord == option;
      final bool showResult = isAnswerChecked;
      final colorScheme = Theme.of(context).colorScheme;

      // กำหนดสีตามสถานะ (ทุกสีใช้ opacity 30%)
      Color? backgroundColor;
      Color? textColor;
      Color borderColor = colorScheme.outline.withOpacity(0.3);

      if (showResult) {
        if (isCorrectOption) {
          backgroundColor = Colors.green.withOpacity(0.3);
          borderColor = Colors.green.withOpacity(0.7);
          textColor = colorScheme.onSurface;
        } else if (isSelected && !isCorrectOption) {
          backgroundColor = Colors.red.withOpacity(0.3);
          borderColor = Colors.red.withOpacity(0.7);
          textColor = colorScheme.onSurface;
        }
      } else if (isSelected) {
        backgroundColor = colorScheme.primary.withOpacity(0.3);
        borderColor = colorScheme.primary.withOpacity(0.7);
        textColor = colorScheme.onSurface;
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: isAnswerChecked ? null : () => onOptionSelected(option),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: backgroundColor ?? colorScheme.surface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                option,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: textColor,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
