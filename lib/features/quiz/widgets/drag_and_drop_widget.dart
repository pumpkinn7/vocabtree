import 'package:flutter/material.dart';
import 'dart:math';

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
  Map<String, String?> currentMatches = {};
  List<String> shuffledTargets = [];

  @override
  void initState() {
    super.initState();
    for (var item in widget.question.draggableItems) {
      currentMatches[item] = null;
    }
    shuffledTargets = List<String>.from(widget.question.targets);
    shuffledTargets.shuffle(Random());
  }

  bool get allPlaced {
    return currentMatches.values.every((target) => target != null);
  }

  void _checkAnswer() {
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
              children: shuffledTargets.map((target) {
                return DragTarget<String>(
                  onWillAccept: (data) => true,
                  onAccept: (data) {
                    setState(() {
                      // เคลียร์ item เดิมที่เคยถูกวางบน target นี้ก่อน
                      for (var key in currentMatches.keys) {
                        if (currentMatches[key] == target) {
                          currentMatches[key] = null;
                        }
                      }
                      currentMatches[data] = target;
                    });
                  },
                  builder: (context, candidateData, rejectedData) {
                    final matchedItem = currentMatches.entries
                        .firstWhere((e) => e.value == target, orElse: () => const MapEntry('', null))
                        .key;

                    return Container(
                      padding: const EdgeInsets.all(8),
                      width: 100,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        color: matchedItem.isNotEmpty ? Colors.green[100] : Colors.white,
                      ),
                      child: Center(
                        child: Text(
                          target,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14),
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
                return Draggable<String>(
                  data: item,
                  feedback: _buildFeedbackItem(item),
                  childWhenDragging: _buildWhenDraggingItem(item),
                  child: _buildDraggableItem(item, placed: currentMatches[item] != null),
                );
              }).toList(),
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
      ),
    );
  }

  Widget _buildDraggableItem(String item, {bool placed = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: placed ? Colors.grey[300] : Colors.blue[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue),
      ),
      child: Text(item, style: const TextStyle(fontSize: 14)),
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
