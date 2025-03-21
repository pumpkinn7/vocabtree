import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class FriendsProgressRanking extends StatelessWidget {
  final String userId;
  const FriendsProgressRanking({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getFriendsProgress(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<Map<String, dynamic>> progressList = snapshot.data ?? [];
        if (progressList.isEmpty) return const SizedBox.shrink();

        return Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.people, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'การจัดอันดับเพื่อน',
                      style: AppTextStyles.subtitle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...List.generate(progressList.length, (index) {
                  final user = progressList[index];
                  final isCurrentUser = user['userId'] == userId;
                  return ListTile(
                    leading: _buildRankBadge(context, index),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${user['username']}${isCurrentUser ? ' (ฉัน)' : ''}',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getSeasonColor(user['currentSeason']),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user['currentSeason'],
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRankBadge(BuildContext context, int index) {
    Color getColor() {
      switch (index) {
        case 0:
          return Colors.amber;
        case 1:
          return Colors.grey[400]!;
        case 2:
          return Colors.brown[300]!;
        default:
          return Colors.grey[300]!;
      }
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: getColor(),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: AppTextStyles.body.copyWith(
            color: index <= 2 ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getFriendsProgress() async {
    try {
      final friendsDoc = await FirebaseFirestore.instance
          .collection('friends')
          .doc(userId)
          .get();
      List<String> friendIds =
          List<String>.from(friendsDoc.data()?['friends'] ?? []);
      friendIds.add(userId);

      List<Map<String, dynamic>> progressList = [];

      for (String id in friendIds) {
        final userDoc =
            await FirebaseFirestore.instance.collection('users').doc(id).get();

        final progressDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(id)
            .collection('progress')
            .doc('unlockedTopics')
            .get();

        if (!progressDoc.exists) continue;

        String currentSeason =
            _determineCurrentSeason(progressDoc.data() ?? {});

        progressList.add({
          'userId': id,
          'username': userDoc.data()?['username'] ?? 'Unknown',
          'currentSeason': currentSeason,
        });
      }

      progressList.sort((a, b) {
        final order = ['Winter', 'Autumn', 'Summer', 'Spring'];
        return order
            .indexOf(a['currentSeason'])
            .compareTo(order.indexOf(b['currentSeason']));
      });

      return progressList;
    } catch (e) {
      return [];
    }
  }

  String _determineCurrentSeason(Map<String, dynamic> progress) {
    final seasons = {
      'Winter': progress['C2'] ?? {},
      'Autumn': progress['C1'] ?? {},
      'Summer': progress['B2'] ?? {},
      'Spring': progress['B1'] ?? {},
    };

    for (var entry in seasons.entries) {
      final topics = entry.value as Map<String, dynamic>;
      if (topics.values.any((v) => v == true)) {
        return entry.key;
      }
    }

    return 'Spring';
  }

  Color _getSeasonColor(String season) {
    switch (season) {
      case 'Winter':
        return const Color(0xFF89CFF0);
      case 'Autumn':
        return const Color(0xFFD2691E);
      case 'Summer':
        return const Color(0xFF90EE90);
      case 'Spring':
        return const Color(0xFFDDA0DD);
      default:
        return Colors.grey;
    }
  }
}
