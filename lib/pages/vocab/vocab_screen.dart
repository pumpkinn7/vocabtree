import 'package:flutter/material.dart';

class VocabScreen extends StatelessWidget {
  const VocabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocab Screen'),
      ),
      body: const Center(
        child: Text('This is the Vocab Screen'),
      ),
    );
  }
}
