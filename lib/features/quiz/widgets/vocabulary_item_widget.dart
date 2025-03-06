import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class VocabularyItemWidget extends StatelessWidget {
  final String title;
  final String level;
  final String difficulty;
  final String imagePath;
  final VoidCallback onTap;

  const VocabularyItemWidget({
    super.key,
    required this.title,
    required this.level,
    required this.difficulty,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          color: Colors.white,
        ),
        child: BootstrapRow(
          children: [
            BootstrapCol(
              sizes: 'col-3 col-sm-2',
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            BootstrapCol(
              sizes: 'col-9 col-sm-10',
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.title,
                    ),
                    const SizedBox(height: 4),
                    Text(level, style: AppTextStyles.label),
                    const SizedBox(height: 4),
                    Text(difficulty, style: AppTextStyles.body),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
