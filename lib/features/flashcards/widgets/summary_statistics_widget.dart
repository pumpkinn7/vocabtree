import 'package:flutter/material.dart';
import '../../../core/theme/text_styles.dart';

class SummaryStatisticsWidget extends StatelessWidget {
  final int totalCount;
  final int knownCount;
  final int unknownCount;
  final int reviewCount;

  const SummaryStatisticsWidget({
    super.key,
    required this.totalCount,
    required this.knownCount,
    required this.unknownCount,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatItem(
              context: context,
              title: 'จำนวนคำศัพท์ทั้งหมด',
              count: totalCount,
              color: colorScheme.primary,
            ),
            _buildStatItem(
              context: context,
              title: 'คำศัพท์ที่รู้',
              count: knownCount,
              color: Colors.green,
            ),
            _buildStatItem(
              context: context,
              title: 'คำศัพท์ที่ไม่รู้',
              count: unknownCount,
              color: Colors.red,
            ),
            _buildStatItem(
              context: context,
              title: 'คำศัพท์ที่ต้องทบทวน',
              count: reviewCount,
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required String title,
    required int count,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: AppTextStyles.body),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Text(
              count.toString(),
              style: AppTextStyles.body.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
