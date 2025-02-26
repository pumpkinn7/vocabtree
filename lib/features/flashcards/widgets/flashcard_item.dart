import 'package:flutter/material.dart';

import '../model/flashcard_topic_model.dart';

/// แสดงการ์ดคำศัพท์
class FlashcardItem extends StatelessWidget {
  final Flashcard flashcard;
  final int currentIndex;
  final int totalItems;
  final bool showMeaning;
  final VoidCallback onDetailPressed;

  const FlashcardItem({
    super.key,
    required this.flashcard,
    required this.currentIndex,
    required this.totalItems,
    required this.showMeaning,
    required this.onDetailPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 1. คำศัพท์
                      Text(
                        showMeaning
                            ? flashcard.definition
                            : flashcard
                                .mainWord, // เปลี่ยนจาก word เป็น mainWord
                        style: const TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 2. ชนิดคำ
                      Text(
                        flashcard.partOfSpeech,
                        style: const TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      // Definition และ CEFR level ถูกลบออกตามที่กำหนด
                    ],
                  ),
                ),
              ),
              // Only keep the detail button
              _buildDetailButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailButton() {
    return Positioned(
      top: 16,
      right: 16,
      child: GestureDetector(
        onTap: onDetailPressed,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: const Text(
            '?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
