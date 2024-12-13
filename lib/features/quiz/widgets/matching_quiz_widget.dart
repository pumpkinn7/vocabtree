import 'package:flutter/material.dart';

import '../model/quiz_question_model.dart';

class MatchingQuizWidget extends StatelessWidget {
  final QuizQuestionModel question;
  final Map<String, String?> userMatches;
  final ValueChanged<Map<String, String?>> onUpdateMatches;
  final bool isAnswerChecked;
  final bool isCorrect;

  const MatchingQuizWidget({
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
              'จับคู่รายการทางซ้ายเข้ากับรายการทางขวา',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            // จัดวางรายการทางซ้ายและรายการทางขวาในรูปแบบแถว
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ซ้าย
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: q.leftItems.map((leftItem) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          leftItem,
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 16),
                // ขวา (Dropdown)
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: q.leftItems.map((leftItem) {
                      final chosen = userMatches[leftItem] != null;
                      bool isCorrect = isAnswerChecked && q.correctMatches[leftItem] == userMatches[leftItem];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: chosen
                                ? (isCorrect ? Colors.green[200] : Colors.red[200])
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: userMatches[leftItem],
                            hint: const Text('เลือกคำตอบ'),
                            isExpanded: true,
                            items: q.rightItems.map((rightItem) {
                              return DropdownMenuItem(
                                value: rightItem,
                                child: Text(rightItem),
                              );
                            }).toList(),
                            onChanged: isAnswerChecked
                                ? null // ปิดการเลือกถ้าทำการตอบแล้ว
                                : (val) {
                              final updatedMatches = Map<String, String?>.from(userMatches);
                              // Clear any existing match for this right item
                              for (var item in q.leftItems) {
                                if (updatedMatches[item] == val) {
                                  updatedMatches[item] = null;
                                }
                              }
                              updatedMatches[leftItem] = val;
                              onUpdateMatches(updatedMatches);
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
