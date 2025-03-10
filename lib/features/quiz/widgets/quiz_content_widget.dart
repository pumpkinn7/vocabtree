import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import '../models/quiz_question_model.dart';
import 'multiple_choice_widget.dart';
import 'progress_bar.dart';

class QuizContentWidget extends StatelessWidget {
  final QuizQuestionModel question;
  final int currentQuestionIndex;
  final int totalQuestions;
  final String? selectedAnswer;
  final bool isAnswerChecked;
  final bool isCorrect;
  final bool isFrequentlyWrong;
  final int wrongCount;
  final Function(String) onOptionSelected;
  final VoidCallback? onCheckAnswer;
  final VoidCallback onSkipQuestion;

  const QuizContentWidget({
    super.key,
    required this.question,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    required this.selectedAnswer,
    required this.isAnswerChecked,
    required this.isCorrect,
    required this.isFrequentlyWrong,
    required this.wrongCount,
    required this.onOptionSelected,
    required this.onCheckAnswer,
    required this.onSkipQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // เพิ่มระยะห่าง 25 ด้านบน ProgressBar
        const SizedBox(height: 25),

        // Progress bar
        ProgressBar(
          current: currentQuestionIndex + 1,
          total: totalQuestions,
        ),
        const SizedBox(height: 16),

        // Question content
        Expanded(
          child: SingleChildScrollView(
            child: MultipleChoiceWidget(
              question: question,
              selectedOption: selectedAnswer,
              onOptionSelected: onOptionSelected,
              isAnswerChecked: isAnswerChecked,
              isCorrect: isCorrect,
              isFrequentlyWrong: isFrequentlyWrong,
              wrongCount: wrongCount,
            ),
          ),
        ),

        // Action buttons
        if (!isAnswerChecked) _buildActionButtons(),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 16),
      child: BootstrapRow(
        children: [
          BootstrapCol(
            sizes: 'col-6',
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ElevatedButton(
                onPressed: onSkipQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: Text('ข้าม', style: AppTextStyles.buttonText),
              ),
            ),
          ),
          BootstrapCol(
            sizes: 'col-6',
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ElevatedButton(
                onPressed: onCheckAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size.fromHeight(50),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: Text('ตรวจ', style: AppTextStyles.buttonText),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
