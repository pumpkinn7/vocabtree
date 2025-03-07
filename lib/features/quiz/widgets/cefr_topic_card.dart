import 'package:flutter/material.dart';
import '../../../core/theme/text_styles.dart';
import '../models/topic_model.dart';

class CefrTopicCard extends StatelessWidget {
  final TopicModel topic;
  final VoidCallback onFlashcardTap;
  final VoidCallback onQuizTap;

  const CefrTopicCard({
    super.key,
    required this.topic,
    required this.onFlashcardTap,
    required this.onQuizTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: topic.isUnlocked ? 1.0 : 0.7,
      child: Stack(
        children: [
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Theme.of(context).dividerColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topic.formattedTitle,
                          style: AppTextStyles.subtitle,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: OutlinedButton.icon(
                                  onPressed:
                                      topic.isUnlocked ? onFlashcardTap : null,
                                  icon: const Icon(Icons.style, size: 20),
                                  label: const Text('Flashcard'),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: ElevatedButton.icon(
                                  onPressed:
                                      topic.isUnlocked ? onQuizTap : null,
                                  icon: const Icon(Icons.quiz, size: 20),
                                  label: const Text('Quiz'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: topic.statusColor,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (topic.imagePath != null)
                    Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context).dividerColor),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                topic.imagePath!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, _, __) => Icon(
                                  Icons.image_not_supported,
                                  size: 40,
                                  color: Theme.of(context).disabledColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'รางวัล',
                            style: AppTextStyles.caption,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (!topic.isUnlocked)
            Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outlined,
                      size: 40,
                      color: Theme.of(context).disabledColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ยังไม่ปลดล็อค',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
