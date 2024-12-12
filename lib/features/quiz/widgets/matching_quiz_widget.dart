import 'package:flutter/material.dart';

import '../model/quiz_question_model.dart';

class MatchingQuizWidget extends StatefulWidget {
  final QuizQuestionModel question;
  final ValueChanged<bool> onAnswered;

  const MatchingQuizWidget({
    super.key,
    required this.question,
    required this.onAnswered,
  });

  @override
  State<MatchingQuizWidget> createState() => _MatchingQuizWidgetState();
}

class _MatchingQuizWidgetState extends State<MatchingQuizWidget> {
  final Map<String, String?> _userMatches = {};

  @override
  void initState() {
    super.initState();
    // เริ่มต้นยังไม่ได้เลือกอะไร
    for (var leftItem in widget.question.leftItems) {
      _userMatches[leftItem] = null;
    }
  }

  bool get allSelected {
    return _userMatches.values.every((value) => value != null);
  }

  void _checkAnswer() {
    final correctMatches = widget.question.correctMatches;
    bool correct = true;
    for (var entry in _userMatches.entries) {
      final leftItem = entry.key;
      final chosenRight = entry.value;
      if (chosenRight == null || correctMatches[leftItem] != chosenRight) {
        correct = false;
        break;
      }
    }
    widget.onAnswered(correct);
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;

    return SingleChildScrollView(
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
          Column(
            children: q.leftItems.map((leftItem) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      leftItem,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: _userMatches[leftItem],
                      hint: const Text('เลือกคำตอบ'),
                      items: q.rightItems.map((rightItem) {
                        return DropdownMenuItem(
                          value: rightItem,
                          child: Text(rightItem),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _userMatches[leftItem] = val;
                        });
                      },
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: allSelected ? _checkAnswer : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('ตรวจคำตอบ'),
            ),
          ),
        ],
      ),
    );
  }
}
