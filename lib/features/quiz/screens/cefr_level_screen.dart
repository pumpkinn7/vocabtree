import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../flashcards/screens/flashcard_topic_screen.dart';
import '../../quiz/screens/quiz_topic_screen.dart';

class CefrLevelScreen extends StatelessWidget {
  final String cefrLevel;

  const CefrLevelScreen({super.key, required this.cefrLevel});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'คำศัพท์ภาษาอังกฤษระดับ $cefrLevel',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('cefr_levels').doc(cefrLevel).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Error loading topics'));
            }

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
                          userId: user?.uid ?? '',
                        ),
                      ),
                    );
                  },
                  onQuizPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizTopicScreen(topic: topicKey),
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

  String _formatTopicName(String topicKey) {
    return topicKey
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Widget _buildProgressItem(
      BuildContext context, {
        required String title,
        VoidCallback? onFlashcardPressed,
        VoidCallback? onQuizPressed,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
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
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: onFlashcardPressed,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                        child: const Text('Flashcard'),
                      ),
                      ElevatedButton(
                        onPressed: onQuizPressed,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        child: const Text('Quiz'),
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
