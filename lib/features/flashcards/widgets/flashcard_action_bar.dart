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
          _buildActionButton(
            'assets/images/Flashcard-1.png',
            40,
            40,
            onNopePressed,
          ),
          _buildActionButton(
            'assets/images/Flashcard-2.png',
            50,
            50,
            onSpeakPressed,
          ),
          _buildActionButton(
            'assets/images/Flashcard-3.png',
            60,
            60,
            onSuperlikePressed,
          ),
          _buildActionButton(
            'assets/images/Flashcard-4.png',
            50,
            50,
            onToggleMeaningPressed,
          ),
          _buildActionButton(
            'assets/images/Flashcard-5.png',
            40,
            40,
            onLikePressed,
          ),
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
