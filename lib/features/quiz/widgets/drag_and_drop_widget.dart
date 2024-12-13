import 'package:flutter/material.dart';

import '../model/quiz_question_model.dart';

class DragAndDropWidget extends StatelessWidget {
  final QuizQuestionModel question;
  final Map<String, String?> userMatches;
  final ValueChanged<Map<String, String?>> onUpdateMatches;
  final bool isAnswerChecked;
  final bool isCorrect;

  const DragAndDropWidget({
    super.key,
    required this.question,
    required this.userMatches,
    required this.onUpdateMatches,
    required this.isAnswerChecked,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    final q = question;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              q.question,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'ลากคำศัพท์ไปวางให้ตรงกับความหมายที่อยู่ด้านบน',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            // แสดงความหมาย: ด้านบน
            Text(
              'ความหมาย:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: q.targets.map((target) {
                bool isCorrectlyMatched = false;
                if (isAnswerChecked) {
                  // Find if the current target is correctly matched
                  isCorrectlyMatched = q.correctMatches.entries.any((entry) => entry.value == target && entry.key == q.draggableItems.firstWhere((item) => userMatches[item] == target, orElse: () => ''));
                }

                return DragTarget<String>(
                  onWillAccept: (data) => !isAnswerChecked,
                  onAccept: isAnswerChecked
                      ? null
                      : (data) {
                    final updatedMatches = Map<String, String?>.from(userMatches);
                    // Clear any existing match for this target
                    for (var item in q.draggableItems) {
                      if (updatedMatches[item] == target) {
                        updatedMatches[item] = null;
                      }
                    }
                    updatedMatches[data] = target;
                    onUpdateMatches(updatedMatches);
                  },
                  builder: (context, candidateData, rejectedData) {
                    final matchedItem = q.draggableItems.firstWhere(
                          (item) => userMatches[item] == target,
                      orElse: () => '',
                    );

                    return Container(
                      padding: const EdgeInsets.all(8),
                      width: 100,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        color: matchedItem.isNotEmpty
                            ? (isCorrectlyMatched ? Colors.green[100] : Colors.red[100])
                            : Colors.white,
                      ),
                      child: Center(
                        child: Text(
                          target,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: isAnswerChecked
                                ? (isCorrectlyMatched ? Colors.green : Colors.red)
                                : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // แสดงคำศัพท์: ด้านล่าง
            Text(
              'คำศัพท์:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: q.draggableItems.map((item) {
                bool isPlaced = userMatches[item] != null;
                bool isCorrect = isAnswerChecked && q.correctMatches[item] == userMatches[item];

                return Draggable<String>(
                  data: item,
                  feedback: _buildFeedbackItem(item),
                  childWhenDragging: _buildWhenDraggingItem(item),
                  // ปิดการลากถ้าทำการตอบแล้ว
                  ignoringFeedbackSemantics: isAnswerChecked,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isPlaced
                          ? (isCorrect ? Colors.green[200] : Colors.red[200])
                          : Colors.blue[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Text(item, style: const TextStyle(fontSize: 14)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            if (isAnswerChecked)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCorrect ? 'ถูกต้อง!' : 'ตอบผิด!',
                    style: TextStyle(
                      color: isCorrect ? Colors.green : Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (!isCorrect)
                    Text(
                      'คำตอบที่ถูกต้อง:',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  if (!isCorrect)
                    ...q.correctMatches.entries.map((entry) {
                      return Text(
                        '${entry.key} : ${entry.value}',
                        style: const TextStyle(fontSize: 16),
                      );
                    }),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackItem(String item) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.blue[200],
        child: Text(item, style: const TextStyle(fontSize: 14)),
      ),
    );
  }

  Widget _buildWhenDraggingItem(String item) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey[300],
      child: Text(item, style: const TextStyle(fontSize: 14, color: Colors.grey)),
    );
  }
}
