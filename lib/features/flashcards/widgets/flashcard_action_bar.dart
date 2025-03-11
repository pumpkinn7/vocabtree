import 'package:flutter/material.dart';

typedef FlashcardActionCallback = void Function();

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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // ปุ่มต่างๆ ที่มีการแก้ไขตรงฟังก์ชัน onTap เพื่อให้การอัพเดตค่าเป็นไปตามลำดับที่ถูกต้อง
          GestureDetector(
            onTap: onNopePressed,
            child: Image.asset(
              'assets/images/Flashcard-1.png',
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
          GestureDetector(
            onTap: onSpeakPressed,
            child: Image.asset(
              'assets/images/Flashcard-2.png',
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            ),
          ),
          GestureDetector(
            onTap: onSuperlikePressed,
            child: Image.asset(
              'assets/images/Flashcard-3.png',
              width: 60,
              height: 60,
              fit: BoxFit.contain,
            ),
          ),
          GestureDetector(
            onTap: onToggleMeaningPressed,
            child: Image.asset(
              'assets/images/Flashcard-4.png',
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            ),
          ),
          GestureDetector(
            onTap: onLikePressed,
            child: Image.asset(
              'assets/images/Flashcard-5.png',
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
