import 'package:flutter/material.dart';

import '../model/flashcard_topic_model.dart';
import '../services/flashcard_service.dart';

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
  final FlashcardService _service;

  FlashcardItem({
    super.key,
    required this.flashcard,
    required this.currentIndex,
    required this.totalItems,
    required this.showMeaning,
  }) : _service = FlashcardService();

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
          child: FutureBuilder<WordDetail?>(
            future: showMeaning ? _service.getWordDetail(flashcard.id) : null,
            builder: (context, snapshot) {
              final detail = snapshot.data;

              return Stack(
                children: [
                  Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            showMeaning && detail != null
                                ? detail.definition
                                : flashcard.mainWord,
                            style: const TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (showMeaning && detail != null) ...[
                            if (detail.partOfSpeech.isNotEmpty) ...[
                              Text(
                                detail.partOfSpeech,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                            // ...rest of the detail display code...
                          ],
                        ],
                      ),
                    ),
                  ),
                  // ...rest of the widget code...
                ],
              );
            },
          ),
        ),
      ),
    );
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
