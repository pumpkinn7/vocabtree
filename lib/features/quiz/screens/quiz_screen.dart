import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vocabtree/features/quiz/screens/cefr_level_screen.dart';
import 'package:vocabtree/features/quiz/widgets/daily_vocabulary_card.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('แบบทดสอบคำศัพท์ภาษาอังกฤษ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const DailyVocabularyCard(),
              const SizedBox(height: 16),
              VocabularyItem(
                title: 'SPRING',
                level: 'คำศัพท์ภาษาอังกฤษ B1',
                difficulty: 'กลาง (Intermediate)',
                imagePath: 'assets/images/oak_6977599.png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CefrLevelScreen(
                        cefrLevel: 'B1',
                        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                      ),
                    ),
                  );
                },
              ),
              VocabularyItem(
                title: 'SUMMER',
                level: 'คำศัพท์ภาษาอังกฤษ B2',
                difficulty: 'กลาง (Intermediate)',
                imagePath: 'assets/images/tree_6977578.png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CefrLevelScreen(
                        cefrLevel: 'B2',
                        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                      ),
                    ),
                  );
                },
              ),
              VocabularyItem(
                title: 'AUTUMN',
                level: 'คำศัพท์ภาษาอังกฤษ C1',
                difficulty: 'กลาง (Intermediate)',
                imagePath: 'assets/images/tree_6977585.png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CefrLevelScreen(
                        cefrLevel: 'C1',
                        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                      ),
                    ),
                  );
                },
              ),
              VocabularyItem(
                title: 'WINTER',
                level: 'คำศัพท์ภาษาอังกฤษ C2',
                difficulty: 'สูง (Advanced)',
                imagePath: 'assets/images/tree_6977597.png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CefrLevelScreen(
                        cefrLevel: 'C2',
                        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                      ),
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
  final String imagePath;
  final VoidCallback onTap;

  const VocabularyItem({
    super.key,
    required this.title,
    required this.level,
    required this.difficulty,
    required this.imagePath,
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
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
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
