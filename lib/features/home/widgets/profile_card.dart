import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final DateTime? joinedAt;
  final String imageUrl;
  final Map<String, dynamic> unlockedTopics;
  final bool isUser;

  final int rewardCount;

  const ProfileCard({
    super.key,
    required this.name,
    required this.joinedAt,
    required this.imageUrl,
    required this.unlockedTopics,
    required this.isUser,
    required this.rewardCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              backgroundImage:
              imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
              child: imageUrl.isEmpty
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(height: 16),

            Text(
              name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),

            Text(
              joinedAt != null
                  ? 'เข้าร่วมเมื่อ: ${joinedAt!.day}/${joinedAt!.month}/${joinedAt!.year}'
                  : 'ไม่ทราบวันที่เข้าร่วม',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 16),

            // progress CEFR
            _buildCefrProgress(),

            const SizedBox(height: 16),
            Text(
              'ครอบครอง: $rewardCount ต้นไม้',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCefrProgress() {
    final b1Count = _countUnlocked('B1');
    final b2Count = _countUnlocked('B2');
    final c1Count = _countUnlocked('C1');
    final c2Count = _countUnlocked('C2');

    return Column(
      children: [
        _buildProgressText('Spring (B1)', b1Count, 7),
        _buildProgressText('Summer (B2)', b2Count, 8),
        _buildProgressText('Autumn (C1)', c1Count, 8),
        _buildProgressText('Winter (C2)', c2Count, 7),
      ],
    );
  }

  int _countUnlocked(String cefrLevel) {
    final levelMap = unlockedTopics[cefrLevel] as Map<String, dynamic>? ?? {};
    return levelMap.values.where((v) => v == true).length;
  }

  Widget _buildProgressText(String label, int count, int total) {
    return Text(
      '$label: $count of $total',
      style: const TextStyle(fontSize: 14),
    );
  }
}