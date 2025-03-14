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
    final colorScheme = Theme.of(context).colorScheme;

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
          padding: const EdgeInsets.all(16.0), // Add padding from card edges
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SECTION 1: User Profile Details
              Container(
                padding: const EdgeInsets.all(24.0), // เพิ่ม padding
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.7),
                  borderRadius:
                      BorderRadius.circular(16), // Full rounded corners
                ),
                child: BootstrapRow(
                  children: [
                    BootstrapCol(
                      sizes: 'col-12',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileHeader(context),
                          if (joinedAt != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'เข้าร่วมเมื่อ ${_formatJoinDate(joinedAt!)}',
                                style: AppTextStyles.caption,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16), // เพิ่มระยะห่าง

              // SECTION 2: Tree Unlocking Display
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 32.0), // ปรับ padding
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.6),
                  borderRadius:
                      BorderRadius.circular(16), // Full rounded corners
                ),
                child: BootstrapRow(
                  children: [
                    BootstrapCol(
                      sizes: 'col-12',
                      child: TreeRewardsRow(unlockedTopics: unlockedTopics),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16), // เพิ่มระยะห่าง

              // SECTION 3: Progress Bars for Each Season
              Container(
                padding: const EdgeInsets.all(24.0), // เพิ่ม padding
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.7),
                  borderRadius:
                      BorderRadius.circular(16), // Full rounded corners
                ),
                child: _buildProgressSection(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build profile header
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

  // Build the progress section with colored progress bars
  Widget _buildProgressSection(BuildContext context) {
    // นับจำนวนเรื่องที่ปลดล็อคในแต่ละระดับ
    int b1Count = _countUnlocked('B1');
    int b2Count = _countUnlocked('B2');
    int c1Count = _countUnlocked('C1');
    int c2Count = _countUnlocked('C2');

    return BootstrapRow(
      children: [
        BootstrapCol(
          sizes: 'col-12',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressBar(
                  context, 'Spring', b1Count, 7, Colors.green[300]!),
              const SizedBox(height: 12),
              _buildProgressBar(
                  context, 'Summer', b2Count, 8, Colors.yellow[700]!),
              const SizedBox(height: 12),
              _buildProgressBar(context, 'Autumn', c1Count, 8, Colors.orange),
              const SizedBox(height: 12),
              _buildProgressBar(
                  context, 'Winter', c2Count, 7, Colors.blue[300]!),
            ],
          ),
        ),
      ],
    );
  }

  // New progress bar widget
  Widget _buildProgressBar(
      BuildContext context, String title, int count, int total, Color color) {
    final progress = count / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w500,
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
        const SizedBox(height: 4),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  int _countUnlocked(String cefrLevel) {
    final levelMap = unlockedTopics[cefrLevel] as Map<String, dynamic>? ?? {};
    return levelMap.values.where((v) => v == true).length;
  }
}
