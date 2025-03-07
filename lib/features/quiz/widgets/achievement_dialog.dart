import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';

class AchievementDialog extends StatelessWidget {
  final String title;
  final String cefrLevel;
  final String imagePath;
  final VoidCallback onStartLearning;

  const AchievementDialog({
    super.key,
    required this.title,
    required this.cefrLevel,
    required this.imagePath,
    required this.onStartLearning,
  });

  IconData _getCefrLevelIcon(String level) {
    switch (level) {
      case 'B1':
        return Icons.local_florist;
      case 'B2':
        return Icons.wb_sunny;
      case 'C1':
        return Icons.eco;
      case 'C2':
        return Icons.ac_unit;
      default:
        return Icons.school;
    }
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

  String _getTopicDescription(String topic) {
    final readableTopic = topic
        .split('_')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');

    return 'คุณได้ปลดล็อกความสำเร็จ ในการเรียนรู้คำศัพท์เกี่ยวกับ "$readableTopic" แล้ว! '
        'ต่อยอดการเรียนรู้ด้วยการทบทวนคำศัพท์ และทำแบบทดสอบเพื่อเพิ่มความแม่นยำ';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 600 ? 600.0 : screenWidth * 0.9;

    return Dialog(
      elevation: 0,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          minWidth: 280,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: BootstrapContainer(
              fluid: true,
              children: [
                BootstrapRow(
                  children: [
                    // Header section
                    BootstrapCol(
                      sizes: 'col-12',
                      child: Row(
                        children: [
                          Icon(
                            _getCefrLevelIcon(cefrLevel),
                            color: _getCefrLevelColor(cefrLevel),
                            size: 24,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'ยินดีด้วย!',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close,
                                color: colorScheme.onSurfaceVariant),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),

                    // Image section
                    BootstrapCol(
                      sizes: 'col-12',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 250,
                            maxWidth: 250,
                          ),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Image.asset(
                              imagePath,
                              fit: BoxFit.contain,
                              errorBuilder: (context, _, __) => Icon(
                                Icons.image_not_supported,
                                size: 80,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Description section
                    BootstrapCol(
                      sizes: 'col-12',
                      child: Text(
                        _getTopicDescription(title),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),

                    // Action Button with top padding
                    BootstrapCol(
                      sizes: 'col-12',
                      child: Padding(
                        padding: const EdgeInsets.only(top: 25),
                        child: FilledButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            onStartLearning();
                          },
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: const Text('เริ่มเรียนด้วย Flashcard'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
