import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import '../../../core/theme/text_styles.dart';
import '../models/topic_model.dart';

class CefrTopicCard extends StatelessWidget {
  final TopicModel topic;
  final VoidCallback onFlashcardTap;
  final VoidCallback onQuizTap;

  // แก้ไขการใช้ key เป็น super parameter
  const CefrTopicCard({
    super.key,
    required this.topic,
    required this.onFlashcardTap,
    required this.onQuizTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: topic.isUnlocked ? 1.0 : 0.5,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 8.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  spreadRadius: 2,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: BootstrapRow(
                children: [
                  BootstrapCol(
                    sizes: 'col-8',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topic.formattedTitle,
                          style: AppTextStyles.subtitle,
                        ),
                        const SizedBox(height: 8),
                        BootstrapRow(
                          children: [
                            BootstrapCol(
                              sizes: 'col-6',
                              child: TextButton(
                                onPressed:
                                    topic.isUnlocked ? onFlashcardTap : null,
                                child: Text('Flashcard',
                                    style: AppTextStyles.buttonText),
                              ),
                            ),
                            BootstrapCol(
                              sizes: 'col-6',
                              child: TextButton(
                                onPressed: topic.isUnlocked ? onQuizTap : null,
                                child: Text('Quiz',
                                    style: AppTextStyles.buttonText),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (topic.imagePath != null)
                    BootstrapCol(
                      sizes: 'col-4',
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              topic.imagePath!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('การปลดล็อค', style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (!topic.isUnlocked)
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.lock,
                  size: 50,
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
