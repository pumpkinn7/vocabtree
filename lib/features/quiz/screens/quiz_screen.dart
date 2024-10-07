import 'package:flutter/material.dart';
import 'package:vocabtree/features/quiz/screens/spring_screen.dart';
import 'package:vocabtree/features/quiz/screens/summer_screen.dart';
import 'package:vocabtree/features/quiz/screens/autumn_screen.dart';
import 'package:vocabtree/features/quiz/screens/winter_screen.dart';

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
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'สวัสดี สวัสดี, คุณ Mr. Johnweeds\nเราคือ Gemini, เป็น Ai ที่สามารถตอบถามได้. นี่คือส่วนข้อมูลเบื้องต้น และทักทาย.',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'หมวดหมู่',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.help_outline),
                        onPressed: () {
                          _showHelpDialog(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
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
                      builder: (context) => const SpringScreen(),
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
                      builder: (context) => const SummerScreen(), // เชื่อมโยงไปยัง SummerScreen
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
                      builder: (context) => const AutumnScreen(), // เชื่อมโยงไปยัง AutumnScreen
                    ),
                  );
                },
              ),
              VocabularyItem(
                title: 'WINTER',
                level: 'คำศัพท์ภาษาอังกฤษ C2',
                difficulty: 'กลาง (Intermediate)',
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WinterScreen(), // เชื่อมโยงไปยัง WinterScreen
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

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'คำอธิบาย',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'คุณสามารถเลือกหัวข้อที่สนใจ เลือกทำ Flashcard เพื่อสำรวจคำศัพท์ใหม่ๆ หรือจะลองทำ Quiz เลยก็ย่อมได้ '
                      'ขอให้สนุกกับการเรียนรู้คำศัพท์',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'ของรางวัล: แน่นอน! หากคุณทำ Quiz ถึงจุดที่ดีขึ้นได้คุณจะได้รับต้นไม้นี้ และนำไปตกแต่งในโปรไฟล์ได้',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.orange,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  width: 50,
                  height: 50,
                  color: Colors.orange, // Replace this with the image widget later
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
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
