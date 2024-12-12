import 'package:flutter/material.dart';

import '../model/quiz_question_model.dart';

class DragAndDropWidget extends StatefulWidget {
  final QuizQuestionModel question;
  final ValueChanged<bool> onAnswered;

  const DragAndDropWidget({
    super.key,
    required this.question,
    required this.onAnswered,
  });

  @override
  State<DragAndDropWidget> createState() => _DragAndDropWidgetState();
}

class _DragAndDropWidgetState extends State<DragAndDropWidget> {
  // เก็บแม็ปชั่วคราวว่า draggableItems ตัวไหนถูกนำไปวางที่ target ใด
  Map<String, String?> currentMatches = {};

  @override
  void initState() {
    super.initState();
    // เริ่มต้นให้ยังไม่มีการจับคู่
    for (var item in widget.question.draggableItems) {
      currentMatches[item] = null;
    }
  }

  bool get allPlaced {
    // เช็คว่า draggableItems ทุกตัวถูกวางลงบน target แล้วหรือไม่
    return currentMatches.values.every((target) => target != null);
  }

  void _checkAnswer() {
    // เทียบ currentMatches กับ correctMatches
    final correctMatches = widget.question.correctMatches;
    bool correct = true;
    for (var entry in currentMatches.entries) {
      final item = entry.key;
      final target = entry.value;
      if (target == null || correctMatches[item] != target) {
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
            'ลากคำศัพท์ทางซ้ายไปวางให้ตรงกับความหมายทางขวา',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // รายการ draggableItems (ต้นทาง)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: q.draggableItems.map((item) {
                    return Draggable<String>(
                      data: item,
                      feedback: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.blue[200],
                          child: Text(item, style: const TextStyle(fontSize: 16)),
                        ),
                      ),
                      childWhenDragging: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(8),
                        color: Colors.grey[300],
                        child: Text(item, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                      ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(8),
                        color: Colors.blue[100],
                        child: Text(item, style: const TextStyle(fontSize: 16)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 20),
              // รายการ targets (ปลายทาง)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: q.targets.map((target) {
                    return DragTarget<String>(
                      onWillAccept: (data) => true,
                      onAccept: (data) {
                        setState(() {
                          // อัปเดตการจับคู่
                          for (var key in currentMatches.keys) {
                            if (currentMatches[key] == target) {
                              // ถ้ามีของเดิมถูกวางที่ target นี้แล้ว ให้เคลียร์ก่อน
                              currentMatches[key] = null;
                            }
                          }
                          currentMatches[data] = target;
                        });
                      },
                      builder: (context, candidateData, rejectedData) {
                        // หารายการที่แมตช์กับ target นี้
                        final matchedItem = currentMatches.entries
                            .firstWhere((e) => e.value == target, orElse: () => const MapEntry('', null))
                            .key;

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(8),
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            color: matchedItem.isNotEmpty && matchedItem != '' ? Colors.green[100] : Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              target,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: allPlaced ? _checkAnswer : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('ตรวจคำตอบ'),
            ),
          ),
        ],
      ),
    );
  }
}
