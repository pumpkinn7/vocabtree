import 'package:flutter/material.dart';

import '../model/flashcard_topic_model.dart';
import '../services/flashcard_service.dart';

class FlashcardDetailDialog extends StatelessWidget {
  final Flashcard flashcard;
  final FlashcardService _service = FlashcardService();

  FlashcardDetailDialog({
    super.key,
    required this.flashcard,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: FutureBuilder<WordDetail?>(
        future: _service.getWordDetail(flashcard.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final detail = snapshot.data;
          if (detail == null) {
            return const Center(child: Text('ไม่พบข้อมูลคำศัพท์'));
          }

          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.mainWord,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (detail.partOfSpeech.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    detail.partOfSpeech,
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                // ...แสดงรายละเอียดอื่นๆ...
              ],
            ),
          );
        },
      ),
    );
  }
}
