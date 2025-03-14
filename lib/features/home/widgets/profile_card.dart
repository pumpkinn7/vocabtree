import 'package:flutter/material.dart';
import 'package:vocabtree/features/rewards/widgets/tree_rewards_row.dart';

class ProfileCard extends StatelessWidget {
  final String username;
  final DateTime? joinedAt;
  final String profileImageUrl;
  final bool isUser;
  final Map<String, dynamic> unlockedTopics;

  const ProfileCard({
    super.key,
    required this.username,
    this.joinedAt,
    required this.profileImageUrl,
    required this.isUser,
    required this.unlockedTopics,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (joinedAt != null)
              Text(
                'เข้าร่วมเมื่อ ${_formatJoinDate(joinedAt!)}',
                style: const TextStyle(fontSize: 14),
              ),
            const SizedBox(height: 8),
            TreeRewardsRow(unlockedTopics: unlockedTopics),
          ],
        ),
      ),
    );
  }

  String _formatJoinDate(DateTime date) {
    final months = [
      'มกราคม',
      'กุมภาพันธ์',
      'มีนาคม',
      'เมษายน',
      'พฤษภาคม',
      'มิถุนายน',
      'กรกฎาคม',
      'สิงหาคม',
      'กันยายน',
      'ตุลาคม',
      'พฤศจิกายน',
      'ธันวาคม'
    ];
    return '${months[date.month - 1]} ${date.year + 543}';
  }
}
