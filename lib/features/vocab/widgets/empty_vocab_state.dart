import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class EmptyVocabState extends StatelessWidget {
  const EmptyVocabState({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: BootstrapRow(
        children: [
          BootstrapCol(
            sizes: 'col-xs-12 col-sm-12 col-md-8 col-lg-6',
            offsets: 'offset-xs-0 offset-sm-0 offset-md-2 offset-lg-3',
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/Flashcard-3.png',
                      height: 100,
                      width: 100,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'ยังไม่มีคำศัพท์ที่บันทึกไว้',
                      style: AppTextStyles.subtitle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'คุณต้องปัด Flashcard ขึ้น เพื่อเพิ่มคำศัพท์ใหม่เข้ามาสู่คลังคำศัพท์ของคุณ',
                      style: AppTextStyles.body
                          .copyWith(color: colorScheme.outline),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
