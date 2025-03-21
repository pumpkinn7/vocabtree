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
                const SizedBox(height: 12),
                // เพิ่มปุ่ม "ตอบผิดบ่อย"
                ElevatedButton.icon(
                  onPressed: () {
                    // ตอนนี้ยังไม่ต้องทำอะไร
                  },
                  icon: Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: Text(
                    'ตอบผิดบ่อย',
                    style: AppTextStyles.caption.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).cardColor,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
