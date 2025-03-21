import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import '../services/word_stats_service.dart';

class TopReviewedWords extends StatelessWidget {
  final String userId;

  const TopReviewedWords({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: WordStatsService().getTopSavedWordsByAllUsers(3),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final words = snapshot.data ?? [];
        if (words.isEmpty) return const SizedBox.shrink();

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.star, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text('คำที่ผู้ใช้บันทึกบ่อยที่สุด',
                        style: AppTextStyles.subtitle),
                  ],
                ),
                const SizedBox(height: 16),
                ...words.asMap().entries.map((entry) {
                  final index = entry.key;
                  final word = entry.value;
                  return _buildWordItem(
                    context: context,
                    index: index,
                    word: word['word'],
                    type: word['type'],
                    count: word['saveCount'],
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWordItem({
    required BuildContext context,
    required int index,
    required String word,
    required String type,
    required int count,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _buildRankBadge(context, index),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (type.isNotEmpty)
                  Text(
                    type,
                    style: AppTextStyles.caption.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'บันทึก $count ครั้ง',
              style: AppTextStyles.caption.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(BuildContext context, int index) {
    final colorScheme = Theme.of(context).colorScheme;

    // สร้างสีพิเศษสำหรับอันดับแรก
    Color badgeColor;
    switch (index) {
      case 0:
        badgeColor = Colors.amber; // สีทองสำหรับอันดับ 1
        break;
      case 1:
        badgeColor = Colors.grey.shade300; // สีเงินสำหรับอันดับ 2
        break;
      case 2:
        badgeColor = Colors.brown.shade300; // สีทองแดงสำหรับอันดับ 3
        break;
      default:
        badgeColor = colorScheme.primaryContainer;
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: TextStyle(
            color: index == 0 ? Colors.black : colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
