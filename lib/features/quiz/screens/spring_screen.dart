import 'package:flutter/material.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

import '../../flashcards/screens/flashcard_screen.dart';
import 'quiz_school_and_education_screen.dart';

class SpringScreen extends StatelessWidget {
  const SpringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SPRING',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text(
              'คำศัพท์ภาษาอังกฤษระดับ B1',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Column(
              children: [
                _buildProgressItem(
                  context,
                  title: '1. School and Education.',
                  flashcardProgress: 0.7, // Example progress
                  quizProgress: 0.6, // Example progress
                  onFlashcardPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FlashcardScreen(),
                      ),
                    );
                  },
                  onQuizPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const QuizSchoolAndEducationScreen(),
                      ),
                    );
                  },
                ),
                _buildProgressItem(
                  context,
                  title: '2. Work and Occupation.',
                ),
                _buildProgressItem(
                  context,
                  title: '3. Health and Wellness.',
                ),
                _buildProgressItem(
                  context,
                  title: '4. Technology and Internet.',
                ),
                _buildProgressItem(
                  context,
                  title: '5. Environment and Nature.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(
    BuildContext context, {
    required String title,
    double flashcardProgress = 0.0,
    double quizProgress = 0.0,
    VoidCallback? onFlashcardPressed,
    VoidCallback? onQuizPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          SimpleCircularProgressBar(
                            size: 50,
                            valueNotifier:
                                ValueNotifier(flashcardProgress * 100),
                            progressStrokeWidth: 8,
                            backStrokeWidth: 4,
                            mergeMode: true,
                            progressColors: const [Colors.orange],
                            fullProgressColor: Colors.orange,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: onFlashcardPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                            child: const Text('Flashcard'),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          SimpleCircularProgressBar(
                            size: 50,
                            valueNotifier: ValueNotifier(quizProgress * 100),
                            progressStrokeWidth: 8,
                            backStrokeWidth: 4,
                            mergeMode: true,
                            progressColors: const [Colors.pink],
                            fullProgressColor: Colors.pink,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: onQuizPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink,
                            ),
                            child: const Text('Quiz'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
