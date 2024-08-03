import 'package:flutter/material.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Screen'),
      ),
      body: const Center(
        child: Text('This is the Quiz Screen'),
      ),
    );
  }
}
