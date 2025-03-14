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
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _buildProfileHeader(context),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 12.0,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'การปลดล็อค',
                      style: AppTextStyles.subtitle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    TreeRewardsRow(unlockedTopics: unlockedTopics),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ความคืบหน้า',
                      style: AppTextStyles.subtitle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildProgressSection(context),
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
                style: AppTextStyles.headline,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                isUser ? 'ฉัน' : 'เพื่อน',
                style: AppTextStyles.label.copyWith(
                  color: isUser ? colorScheme.primary : colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context) {
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
            mainAxisSize: MainAxisSize.min, // Use minimum space needed
            children: [
              _buildProgressBar(
                  context, 'Spring', b1Count, 7, Colors.green[300]!),
              const SizedBox(height: 8), // Reduce spacing between bars
              _buildProgressBar(
                  context, 'Summer', b2Count, 8, Colors.yellow[700]!),
              const SizedBox(height: 8),
              _buildProgressBar(context, 'Autumn', c1Count, 8, Colors.orange),
              const SizedBox(height: 8),
              _buildProgressBar(
                  context, 'Winter', c2Count, 7, Colors.blue[300]!),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(
      BuildContext context, String title, int count, int total, Color color) {
    final progress = count / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
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
