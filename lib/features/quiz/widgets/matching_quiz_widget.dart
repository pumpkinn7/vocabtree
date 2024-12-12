import 'dart:math';
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
  List<String> shuffledRightItems = [];

  @override
  void initState() {
    super.initState();
    for (var leftItem in widget.question.leftItems) {
      _userMatches[leftItem] = null;
    }

    shuffledRightItems = List<String>.from(widget.question.rightItems);
    shuffledRightItems.shuffle(Random());
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

            // ใช้ ListView แบบ shrinkWrap เพื่อจัดให้อยู่ในแนวตั้ง
            // หรือใช้ Column + SizedBox ให้เว้นระยะห่าง
            // ที่นี่จะใช้ Column + SizedBox และจัด align ให้ดูกลาง
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ซ้าย
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.question.leftItems.map((leftItem) {
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
                    children: widget.question.leftItems.map((leftItem) {
                      final chosen = _userMatches[leftItem] != null;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: chosen ? Colors.yellow[100] : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _userMatches[leftItem],
                            hint: const Text('เลือกคำตอบ'),
                            isExpanded: true,
                            items: shuffledRightItems.map((rightItem) {
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
            Center(
              child: ElevatedButton(
                onPressed: allSelected ? _checkAnswer : null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('ตรวจคำตอบ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
