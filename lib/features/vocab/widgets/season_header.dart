import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class SeasonHeader extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String seasonName;
  final String description;
  final String backgroundImage;

  const SeasonHeader({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.seasonName,
    required this.description,
    required this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // ภาพพื้นหลัง
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  backgroundImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // เนื้อหา
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: iconColor,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      seasonName,
                      style: AppTextStyles.subtitle,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
