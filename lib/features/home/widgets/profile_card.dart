import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import 'package:vocabtree/features/rewards/widgets/tree_rewards_row.dart';

class ProfileCard extends StatelessWidget {
  final String username;
  final DateTime? joinedAt;
  final String profileImageUrl;
  final bool isUser;
  final Map<String, dynamic> unlockedTopics;
  final String backgroundImage;

  const ProfileCard({
    super.key,
    required this.username,
    this.joinedAt,
    required this.profileImageUrl,
    required this.isUser,
    required this.unlockedTopics,
    required this.backgroundImage,
  });

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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage(backgroundImage),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BootstrapRow(
            children: [
              BootstrapCol(
                sizes: 'col-12',
                child: Column(
                  children: [
                    // ส่วนหัวของการ์ด (รูปโปรไฟล์และชื่อ)
                    _buildProfileHeader(context),

                    const SizedBox(height: 16),

                    // ส่วนของข้อมูลเพิ่มเติม
                    if (joinedAt != null)
                      Text(
                        'เข้าร่วมเมื่อ ${_formatJoinDate(joinedAt!)}',
                        style: AppTextStyles.caption,
                      ),

                    const SizedBox(height: 16),

                    // ส่วนของไอคอนต้นไม้
                    TreeRewardsRow(unlockedTopics: unlockedTopics),

                    // ส่วนสถิติในการเล่น
                    const SizedBox(height: 16),
                    _buildStatistics(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage:
              profileImageUrl.isNotEmpty ? NetworkImage(profileImageUrl) : null,
          child: profileImageUrl.isEmpty
              ? Icon(Icons.person, size: 30, color: colorScheme.onPrimary)
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: AppTextStyles.subtitle,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                isUser ? 'คุณ' : 'เพื่อน',
                style: AppTextStyles.caption.copyWith(
                  color: isUser ? colorScheme.primary : colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics(BuildContext context) {
    // นับจำนวนเรื่องที่ปลดล็อคในแต่ละระดับ
    int b1Count = _countUnlocked('B1');
    int b2Count = _countUnlocked('B2');
    int c1Count = _countUnlocked('C1');
    int c2Count = _countUnlocked('C2');

    return BootstrapRow(
      children: [
        BootstrapCol(
          sizes: 'col-6',
          child: _buildStatItem(context, 'Spring', b1Count, 7),
        ),
        BootstrapCol(
          sizes: 'col-6',
          child: _buildStatItem(context, 'Summer', b2Count, 8),
        ),
        BootstrapCol(
          sizes: 'col-6',
          child: _buildStatItem(context, 'Autumn', c1Count, 8),
        ),
        BootstrapCol(
          sizes: 'col-6',
          child: _buildStatItem(context, 'Winter', c2Count, 7),
        ),
      ],
    );
  }

  Widget _buildStatItem(
      BuildContext context, String title, int count, int total) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: AppTextStyles.caption.copyWith(
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          Text(
            '$count/$total',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  int _countUnlocked(String cefrLevel) {
    final levelMap = unlockedTopics[cefrLevel] as Map<String, dynamic>? ?? {};
    return levelMap.values.where((v) => v == true).length;
  }
}
