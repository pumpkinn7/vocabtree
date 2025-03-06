import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class VocabularyGuideDialog extends StatelessWidget {
  const VocabularyGuideDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      surfaceTintColor: colorScheme.surface,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('คู่มือระดับคำศัพท์', style: AppTextStyles.title),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: BootstrapContainer(
                  fluid: true,
                  padding: EdgeInsets.zero,
                  children: [
                    BootstrapRow(
                      children: [
                        BootstrapCol(
                          sizes: 'col-12',
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'ระดับความยากของคำศัพท์แบ่งตามฤดูกาล',
                              style: AppTextStyles.subtitle.copyWith(
                                color: colorScheme.onSecondaryContainer,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Spring (B1)
                    _buildSeasonRow(
                      colorScheme: colorScheme,
                      title: 'Spring (B1)',
                      description:
                          'ระดับพื้นฐานถึงปานกลาง เนื้อหาเกี่ยวกับชีวิตประจำวัน การศึกษา ความบันเทิง ธรรมชาติและสิ่งแวดล้อม',
                      imagePath: 'assets/images/oak_6977599.png',
                      level: 'B1',
                    ),
                    const SizedBox(height: 16),

                    // Summer (B2)
                    _buildSeasonRow(
                      colorScheme: colorScheme,
                      title: 'Summer (B2)',
                      description:
                          'ระดับปานกลาง ครอบคลุมหัวข้อที่ซับซ้อนมากขึ้น เช่น การตกแต่งบ้าน กิจกรรมกลางแจ้ง ดนตรี การออกกำลังกาย',
                      imagePath: 'assets/images/tree_6977578.png',
                      level: 'B2',
                    ),
                    const SizedBox(height: 16),

                    // Autumn (C1)
                    _buildSeasonRow(
                      colorScheme: colorScheme,
                      title: 'Autumn (C1)',
                      description:
                          'ระดับกลางค่อนข้างสูง เนื้อหาเชิงวิชาการ วิทยาศาสตร์ เทคโนโลยี การเมือง และธุรกิจ',
                      imagePath: 'assets/images/tree_6977585.png',
                      level: 'C1',
                    ),
                    const SizedBox(height: 16),

                    // Winter (C2)
                    _buildSeasonRow(
                      colorScheme: colorScheme,
                      title: 'Winter (C2)',
                      description:
                          'ระดับสูง ศัพท์ที่ใช้ในการสื่อสารระดับเชี่ยวชาญ ปรัชญา การแพทย์ขั้นสูง กฎหมาย และวรรณกรรม',
                      imagePath: 'assets/images/tree_6977597.png',
                      level: 'C2',
                    ),
                    const SizedBox(height: 24),

                    BootstrapRow(
                      children: [
                        BootstrapCol(
                          sizes: 'col-12',
                          child: Card(
                            color:
                                colorScheme.tertiaryContainer.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.lightbulb_outlined,
                                        color: colorScheme.tertiary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'ทำไมแบ่งเป็นฤดู?',
                                        style: AppTextStyles.subtitle.copyWith(
                                          color:
                                              colorScheme.onTertiaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'ระบบของเราออกแบบให้การเรียนรู้เป็นเหมือนวงจรธรรมชาติ เริ่มจากระดับง่าย (Spring) ไปสู่ระดับที่ซับซ้อนมากขึ้น (Winter) เป็นการเติบโตทางภาษาไปตามฤดูกาล เพื่อให้ง่ายต่อการจดจำและสร้างกระบวนการเรียนรู้ที่เป็นธรรมชาติ',
                                    style: AppTextStyles.body.copyWith(
                                      color: colorScheme.onTertiaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('เข้าใจแล้ว', style: AppTextStyles.buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonRow({
    required ColorScheme colorScheme,
    required String title,
    required String description,
    required String imagePath,
    required String level,
  }) {
    // กำหนดสีตามระดับ CEFR
    Color levelColor;
    switch (level) {
      case 'B1':
        levelColor = Colors.green;
        break;
      case 'B2':
        levelColor = Colors.amber;
        break;
      case 'C1':
        levelColor = Colors.deepOrange;
        break;
      case 'C2':
        levelColor = Colors.blueGrey;
        break;
      default:
        levelColor = colorScheme.primary;
    }

    return BootstrapRow(
      children: [
        BootstrapCol(
          sizes: 'col-12',
          child: Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BootstrapRow(
                children: [
                  // รูปภาพฤดูกาล
                  BootstrapCol(
                    sizes: 'col-xs-4 col-md-3',
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset(
                                imagePath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceVariant,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: levelColor.withOpacity(0.8),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  level,
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // เนื้อหา
                  BootstrapCol(
                    sizes: 'col-xs-8 col-md-9',
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.subtitle
                                .copyWith(color: levelColor),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description,
                            style: AppTextStyles.body,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
