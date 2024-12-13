import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../model/quiz_question_model.dart';

class MultipleChoiceWidget extends StatefulWidget {
  final QuizQuestionModel question;
  final String? selectedOption;
  final ValueChanged<String?> onOptionSelected;
  final bool isAnswerChecked;
  final bool isCorrect;

  const MultipleChoiceWidget({
    super.key,
    required this.question,
    required this.selectedOption,
    required this.onOptionSelected,
    required this.isAnswerChecked,
    required this.isCorrect,
  });

  @override
  State<MultipleChoiceWidget> createState() => _MultipleChoiceWidgetState();
}

class _MultipleChoiceWidgetState extends State<MultipleChoiceWidget> {
  late FlutterTts _flutterTts;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("en-US"); // ตั้งค่าให้เป็นภาษาอังกฤษ
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  String _extractWord(String question) {
    final regExp = RegExp(r"'(.*?)'"); // ดึงข้อความใน ' '
    final match = regExp.firstMatch(question);
    return match != null ? match.group(1)! : question; // ถ้าหาไม่เจอ ให้คืนคำถามเดิม
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ประโยคคำถาม
        Text(
          "What is the meaning of",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // คำศัพท์และปุ่มฟังเสียง
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.volume_up, color: Colors.blue),
              onPressed: () {
                final word = _extractWord(q.question);
                _speak(word); // เล่นเสียงเฉพาะคำศัพท์
              },
            ),
            Expanded(
              child: Text(
                _extractWord(q.question), // แสดงเฉพาะคำศัพท์
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // ตัวเลือกคำตอบ
        ...q.options.map((option) {
          Color? optionColor;
          if (widget.isAnswerChecked) {
            if (option == q.correctAnswer) {
              optionColor = Colors.green[200];
            } else if (option == widget.selectedOption && option != q.correctAnswer) {
              optionColor = Colors.red[200];
            }
          }
          return RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: widget.selectedOption,
            onChanged: widget.isAnswerChecked
                ? null
                : (val) {
              widget.onOptionSelected(val);
            },
            tileColor: optionColor,
          );
        }),
        const SizedBox(height: 16),
        // แสดงผลลัพธ์หลังการตรวจสอบ
        if (widget.isAnswerChecked)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              widget.isCorrect ? 'ถูกต้อง!' : 'ตอบผิด!',
              style: TextStyle(
                color: widget.isCorrect ? Colors.green : Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}
