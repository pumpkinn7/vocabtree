import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../core/theme/text_styles.dart';

class VocabLoading extends StatelessWidget {
  const VocabLoading({super.key});

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
              'assets/animations/Animation - 1741194794564.json',
              frameRate: FrameRate.max,
            ),
          ),
          const SizedBox(height: 16),
          Text("รอสักครู่...", style: AppTextStyles.subtitle),
        ],
      ),
    );
  }
}
