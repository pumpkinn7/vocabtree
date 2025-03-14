import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class TreeRewardsRow extends StatefulWidget {
  final Map<String, dynamic> unlockedTopics;

  const TreeRewardsRow({super.key, required this.unlockedTopics});

  @override
  State<TreeRewardsRow> createState() => _TreeRewardsRowState();
}

class _TreeRewardsRowState extends State<TreeRewardsRow> {
  final PageController _pageController = PageController(viewportFraction: 0.4);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _isUnlocked(String topic, String level) {
    final levelTopics = widget.unlockedTopics[level] as Map<String, dynamic>?;
    return levelTopics?[topic] == true;
  }

  String _formatTopicName(String topic) {
    return topic
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 80,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: treeRewards.length,
            itemBuilder: (context, index) {
              final reward = treeRewards[index];
              final isUnlocked =
                  _isUnlocked(reward['topic']!, reward['level']!);
              final formattedTopic = _formatTopicName(reward['topic']!);

              return AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: index == _currentPage ? 1.0 : 0.5,
                child: Transform.scale(
                  scale: index == _currentPage ? 1.0 : 0.8,
                  child: Container(
                    padding: const EdgeInsets.all(4.0),
                    margin: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/${reward['image']}',
                          width: 45,
                          height: 45,
                          opacity:
                              AlwaysStoppedAnimation(isUnlocked ? 1.0 : 0.3),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          formattedTopic,
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: isUnlocked
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            treeRewards.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: index == _currentPage ? 12 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: index == _currentPage
                    ? colorScheme.primary
                    : colorScheme.primary.withOpacity(0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
