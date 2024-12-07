import 'package:flutter/material.dart';
import 'package:vocabtree/features/quiz/screens/cefr_level_screen.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('เรียนรู้คำศัพท์'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 150,
                width: double.infinity,
                color: Colors.grey,
                child: const Center(
                  child: Text(
                    'CEFR เป็นเครื่องมือที่สำคัญที่ช่วยพัฒนาทักษะการสอนภาษาอังกฤษได้อย่างมีประสิทธิภาพ\nทำให้การเรียนภาษาเป็นไปตามมาตรฐานเดียวกัน และใช้ได้ทั่วโลก.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              VocabularyItem(
                title: 'SPRING',
                level: 'คำศัพท์ภาษาอังกฤษ B1',
                difficulty: 'กลาง (Intermediate)',
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CefrLevelScreen(cefrLevel: 'B1'),
                    ),
                  );
                },
              ),
              VocabularyItem(
                title: 'SUMMER',
                level: 'คำศัพท์ภาษาอังกฤษ B2',
                difficulty: 'กลาง (Intermediate)',
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CefrLevelScreen(cefrLevel: 'B2'),
                    ),
                  );
                },
              ),
              VocabularyItem(
                title: 'AUTUMN',
                level: 'คำศัพท์ภาษาอังกฤษ C1',
                difficulty: 'กลาง (Intermediate)',
                color: Colors.red,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CefrLevelScreen(cefrLevel: 'C1'),
                    ),
                  );
                },
              ),
              VocabularyItem(
                title: 'WINTER',
                level: 'คำศัพท์ภาษาอังกฤษ C2',
                difficulty: 'สูง (Advanced)',
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CefrLevelScreen(cefrLevel: 'C2'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VocabularyItem extends StatelessWidget {
  final String title;
  final String level;
  final String difficulty;
  final Color color;
  final VoidCallback onTap;

  const VocabularyItem({
    super.key,
    required this.title,
    required this.level,
    required this.difficulty,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                color: color,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(level),
                  const SizedBox(height: 4),
                  Text(difficulty),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
