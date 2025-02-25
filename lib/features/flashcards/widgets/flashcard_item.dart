import 'package:flutter/material.dart';

import '../model/flashcard_topic_model.dart';

/// แสดงการ์ดคำศัพท์
class FlashcardItem extends StatelessWidget {
  final Flashcard flashcard;
  final int currentIndex;
  final int totalItems;
  final bool showMeaning;

  const FlashcardItem({
    super.key,
    required this.flashcard,
    required this.currentIndex,
    required this.totalItems,
    required this.showMeaning,
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
                        showMeaning ? flashcard.definition : flashcard.word,
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
                      const SizedBox(height: 25),

                      // 3. คำนิยาม (definition) - แก้ไขให้แสดง definition แทนตัวอย่างประโยค
                      const Text(
                        'definition:',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        flashcard
                            .definition, // แก้จาก flashcard.exampleSentence['sentence'] เป็น flashcard.definition
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 25),

                      // 4. ระดับ CEFR
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getCefrLevelColor(flashcard.cefrLevel),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              'CEFR: ${flashcard.cefrLevel}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              _buildIndexIndicator(currentIndex, totalItems),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndexIndicator(int currentIndex, int totalItems) {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '$currentIndex of $totalItems',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getCefrLevelColor(String cefrLevel) {
    switch (cefrLevel) {
      case 'A1':
        return Colors.green.shade300;
      case 'A2':
        return Colors.green;
      case 'B1':
        return Colors.blue.shade300;
      case 'B2':
        return Colors.blue;
      case 'C1':
        return Colors.purple.shade300;
      case 'C2':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
