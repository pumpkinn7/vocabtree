import 'package:flutter/material.dart';

class TreeRewardsRow extends StatelessWidget {
  final Map<String, dynamic> unlockedTopics;

  const TreeRewardsRow({super.key, required this.unlockedTopics});

  bool _isUnlocked(String topic, String level) {
    final levelTopics = unlockedTopics[level] as Map<String, dynamic>?;
    return levelTopics?[topic] == true;
  }

  @override
  Widget build(BuildContext context) {
    final treeRewards = [
      {'image': 'oak_6977599.png', 'topic': 'daily_life', 'level': 'B1'},
      {
        'image': 'tree_6977578.png',
        'topic': 'gardening_and_landscaping',
        'level': 'B2'
      },
      {
        'image': 'tree_6977580.png',
        'topic': 'pet_care_and_animal_welfare',
        'level': 'B2'
      },
      {'image': 'tree_6977585.png', 'topic': 'fashion_trends', 'level': 'C1'},
      {
        'image': 'tree_6977597.png',
        'topic': 'cosmic_discoveries',
        'level': 'C2'
      },
      {'image': 'tree_6977598.png', 'topic': 'smart_automation', 'level': 'C2'}
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: treeRewards
            .map((reward) => Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.asset(
                    'assets/images/${reward['image']}',
                    width: 32,
                    height: 32,
                    opacity: AlwaysStoppedAnimation(
                        _isUnlocked(reward['topic']!, reward['level']!)
                            ? 1.0
                            : 0.5),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
