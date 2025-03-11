import 'package:flutter/material.dart';
import '../../../core/theme/text_styles.dart';
import '../model/flashcard_topic_model.dart';

/// แสดงการ์ดคำศัพท์
class FlashcardItem extends StatelessWidget {
  final Flashcard flashcard;
  final int currentIndex;
  final int totalItems;
  final bool showMeaning;
  final bool showThaiTranslation; // เพิ่มพารามิเตอร์
  final String thaiTranslation; // เพิ่มพารามิเตอร์
  final bool isTranslating; // เพิ่มพารามิเตอร์
  final VoidCallback onDetailPressed;

  const FlashcardItem({
    super.key,
    required this.flashcard,
    required this.currentIndex,
    required this.totalItems,
    required this.showMeaning,
    required this.showThaiTranslation, // เพิ่มพารามิเตอร์
    required this.thaiTranslation, // เพิ่มพารามิเตอร์
    required this.isTranslating, // เพิ่มพารามิเตอร์
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
      // กลับไปใช้ขนาดการ์ดแบบเดิม
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
