import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../core/theme/text_styles.dart';

class FlashcardLoading extends StatelessWidget {
  const FlashcardLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 200,
            width: 200,
            child: Lottie.asset(
              'assets/animations/Animation - 1741196193367.json',
              frameRate: FrameRate.max,
            ),
          ),
          const SizedBox(height: 16),
          Text("กำลังจัดเตรียมคำศัพท์...", style: AppTextStyles.subtitle),
        ],
      ),
    );
  }
}
