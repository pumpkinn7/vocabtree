import 'package:flutter/material.dart';
import '../../../core/theme/text_styles.dart';
import '../../../features/flashcards/model/flashcard_topic_model.dart';

class ReviewFlashcardItem extends StatelessWidget {
  final Flashcard flashcard;
  final int currentIndex;
  final int totalItems;
  final bool showMeaning;
  final bool showThaiTranslation;
  final String thaiTranslation;
  final bool isTranslating;
  final VoidCallback onDetailPressed;

  const ReviewFlashcardItem({
    super.key,
    required this.flashcard,
    required this.currentIndex,
    required this.totalItems,
    required this.showMeaning,
    required this.showThaiTranslation,
    required this.thaiTranslation,
    required this.isTranslating,
    required this.onDetailPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // กำหนดข้อความที่จะแสดง
    String displayText;
    bool isItalic = false;

    if (isTranslating) {
      displayText = 'กำลังแปล...';
      isItalic = true;
    } else if (showThaiTranslation) {
      displayText = thaiTranslation;
      isItalic = true;
    } else if (showMeaning) {
      displayText = flashcard.definition;
    } else {
      displayText = flashcard.mainWord;
    }

    return Card(
      elevation: 8,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      displayText,
                      style: AppTextStyles.headline.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontStyle:
                            isItalic ? FontStyle.italic : FontStyle.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // แสดงชนิดคำตลอดเวลาโดยไม่ขึ้นกับสถานะการแปล
                    Text(
                      flashcard.partOfSpeech,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Icon(
                Icons.info_outline,
                color: colorScheme.primary,
              ),
              onPressed: onDetailPressed,
            ),
          ),
        ],
      ),
    );
  }
}
