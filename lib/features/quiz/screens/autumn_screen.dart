import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // เพิ่มการนำเข้า Firebase Auth
import 'package:flutter/material.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import '../../flashcards/screens/flashcard_topic_screen.dart';
import '../../quiz/screens/quiz_topic_screen.dart'; // นำเข้า QuizTopicScreen

class AutumnScreen extends StatelessWidget {
  const AutumnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser; // ดึง userId

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AUTUMN',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            Text(
              'คำศัพท์ภาษาอังกฤษระดับ C1',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('cefr_levels').doc('C1').get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Error loading topics'));
            }

            // ดึงหัวข้อจาก Firebase
            final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
            final topics = data['topics'] as Map<String, dynamic>? ?? {};

            return ListView.builder(
              itemCount: topics.keys.length,
              itemBuilder: (context, index) {
                final topicKey = topics.keys.elementAt(index);

                return _buildProgressItem(
                  context,
                  title: '${index + 1}. ${_formatTopicName(topicKey)}',
                  onFlashcardPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FlashcardScreen(
                          topic: topicKey,
                          userId: user?.uid ?? '', // ส่ง userId ที่ถูกต้อง
                        ),
                      ),
                    );
                  },
                  onQuizPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizTopicScreen(topic: topicKey), // เปลี่ยนไปยัง QuizTopicScreen
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ชื่อหัวข้อ
  String _formatTopicName(String topicKey) {
    return topicKey
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
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
              color: Colors.red,
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
                            valueNotifier: ValueNotifier(flashcardProgress * 100),
                            progressStrokeWidth: 8,
                            backStrokeWidth: 4,
                            mergeMode: true,
                            progressColors: const [Colors.red],
                            fullProgressColor: Colors.red,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: onFlashcardPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Flashcard'),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Column(
                        children: [
                          SimpleCircularProgressBar(
                            size: 50,
                            valueNotifier: ValueNotifier(quizProgress * 100),
                            progressStrokeWidth: 8,
                            backStrokeWidth: 4,
                            mergeMode: true,
                            progressColors: const [Colors.blue],
                            fullProgressColor: Colors.blue,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: onQuizPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
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
