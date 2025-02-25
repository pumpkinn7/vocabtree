import 'package:flutter/material.dart';

import '../model/flashcard_topic_model.dart';

export 'flashcard_action_bar.dart';
export 'flashcard_detail_dialog.dart';
export 'flashcard_header.dart';
export 'flashcard_item.dart';

/// ส่วนหัวของหน้า Flashcard
class FlashcardHeader extends StatelessWidget implements PreferredSizeWidget {
  final String topic;

  const FlashcardHeader({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FLASHCARD',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          Text(
            '${topic.replaceAll('_', ' ').toUpperCase()}.',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

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
                        style: const TextStyle(fontSize: 16),
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
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              ),
            ],
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

/// แถบปุ่มกดด้านล่าง
class FlashcardActionBar extends StatelessWidget {
  final VoidCallback onNopePressed;
  final VoidCallback onSpeakPressed;
  final VoidCallback onSuperlikePressed;
  final VoidCallback onToggleMeaningPressed;
  final VoidCallback onLikePressed;

  const FlashcardActionBar({
    super.key,
    required this.onNopePressed,
    required this.onSpeakPressed,
    required this.onSuperlikePressed,
    required this.onToggleMeaningPressed,
    required this.onLikePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
              'assets/images/Flashcard-1.png', 40, 40, onNopePressed),
          _buildActionButton(
              'assets/images/Flashcard-2.png', 50, 50, onSpeakPressed),
          _buildActionButton(
              'assets/images/Flashcard-3.png', 60, 60, onSuperlikePressed),
          _buildActionButton(
              'assets/images/Flashcard-4.png', 50, 50, onToggleMeaningPressed),
          _buildActionButton(
              'assets/images/Flashcard-5.png', 40, 40, onLikePressed),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String imagePath,
    double width,
    double height,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: BoxFit.contain,
      ),
    );
  }
}
