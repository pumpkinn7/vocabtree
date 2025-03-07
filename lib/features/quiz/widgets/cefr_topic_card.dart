import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import '../../../core/theme/text_styles.dart';
import '../models/topic_model.dart';
import 'achievement_dialog.dart';

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

  // Method to show full image dialog
  void _showImageDialog(BuildContext context) {
    if (topic.imagePath == null) return;

    showDialog(
      context: context,
      builder: (context) => AchievementDialog(
        title: topic.title,
        cefrLevel: topic.cefrLevel,
        imagePath: topic.imagePath!,
        onStartLearning: onFlashcardTap,
      ),
    );
  }

  Color _getCefrLevelColor(String level) {
    switch (level) {
      case 'B1':
        return Colors.green;
      case 'B2':
        return Colors.orange;
      case 'C1':
        return Colors.deepOrange;
      case 'C2':
        return Colors.blueGrey;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Opacity(
      opacity: topic.isUnlocked ? 1.0 : 0.7,
      child: Stack(
        children: [
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 3,
            surfaceTintColor: colorScheme.surfaceTint,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                  color: colorScheme.outlineVariant.withOpacity(0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: BootstrapContainer(
                fluid: true,
                padding: EdgeInsets.zero,
                children: [
                  BootstrapRow(
                    children: [
                      BootstrapCol(
                        sizes: 'col-12',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title and image icon in same row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    topic.formattedTitle,
                                    style: AppTextStyles.subtitle,
                                  ),
                                ),
                                if (topic.imagePath != null)
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => _showImageDialog(context),
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: colorScheme.outline
                                                .withOpacity(0.3),
                                          ),
                                        ),
                                        child: Image.asset(
                                          topic.imagePath!,
                                          width: 28,
                                          height: 28,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, _, __) =>
                                              Icon(
                                            Icons.emoji_events,
                                            size: 24,
                                            color: _getCefrLevelColor(
                                                topic.cefrLevel),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            BootstrapRow(
                              children: [
                                // Flashcard Button
                                BootstrapCol(
                                  sizes: 'col-xs-6 col-sm-6 col-md-6 col-lg-4',
                                  child: OutlinedButton(
                                    onPressed: topic.isUnlocked
                                        ? onFlashcardTap
                                        : null,
                                    child: Text('Flashcard',
                                        style: AppTextStyles.buttonText),
                                  ),
                                ),
                                // Quiz Button
                                BootstrapCol(
                                  sizes: 'col-xs-6 col-sm-6 col-md-6 col-lg-4',
                                  child: OutlinedButton(
                                    onPressed:
                                        topic.isUnlocked ? onQuizTap : null,
                                    child: Text('Quiz',
                                        style: AppTextStyles.buttonText),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Lock overlay
          if (!topic.isUnlocked)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_outlined,
                        size: 40,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ยังไม่ปลดล็อค',
                        style: AppTextStyles.caption.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
