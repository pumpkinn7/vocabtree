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
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: BootstrapRow(
          children: [
            // Image column
            BootstrapCol(
              sizes: 'col-xs-3 col-sm-3 col-md-2 col-lg-2',
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Content column
            BootstrapCol(
              sizes: 'col-xs-9 col-sm-9 col-md-10 col-lg-10',
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.title,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      level,
                      style: AppTextStyles.label,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      difficulty,
                      style: AppTextStyles.body,
                    ),
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
