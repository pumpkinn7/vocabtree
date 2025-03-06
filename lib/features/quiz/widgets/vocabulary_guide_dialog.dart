import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class VocabularyGuideDialog extends StatelessWidget {
  const VocabularyGuideDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    // กำหนดความกว้างของ dialog ตามขนาดหน้าจอ
    double dialogWidth;
    if (screenWidth < 400) {
      dialogWidth = screenWidth * 0.9; // xs
    } else if (screenWidth < 600) {
      dialogWidth = screenWidth * 0.8; // sm
    } else if (screenWidth < 900) {
      dialogWidth = screenWidth * 0.7; // md
    } else {
      dialogWidth = screenWidth * 0.5; // lg
    }

    return Dialog(
      surfaceTintColor: colorScheme.surface,
      elevation: 3,
      insetPadding: EdgeInsets.symmetric(
          horizontal: (screenWidth - dialogWidth) / 2, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: SizedBox(
        width: dialogWidth, // กำหนดความกว้างของ dialog
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('คู่มือระดับคำศัพท์', style: AppTextStyles.title),
              const SizedBox(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Spring (B1)
                      _buildSeasonCard(
                        context: context,
                        colorScheme: colorScheme,
                        title: 'Spring (B1)',
                        description:
                            'ระดับพื้นฐานถึงปานกลาง เนื้อหาเกี่ยวกับชีวิตประจำวัน การศึกษา ความบันเทิง ธรรมชาติและสิ่งแวดล้อม',
                        imagePath: 'assets/images/oak_6977599.png',
                        level: 'B1',
                      ),
                      const SizedBox(height: 20),

                      // Summer (B2)
                      _buildSeasonCard(
                        context: context,
                        colorScheme: colorScheme,
                        title: 'Summer (B2)',
                        description:
                            'ระดับปานกลาง ครอบคลุมหัวข้อที่ซับซ้อนมากขึ้น เช่น การตกแต่งบ้าน กิจกรรมกลางแจ้ง ดนตรี การออกกำลังกาย',
                        imagePath: 'assets/images/tree_6977578.png',
                        level: 'B2',
                      ),
                      const SizedBox(height: 20),

                      // Autumn (C1)
                      _buildSeasonCard(
                        context: context,
                        colorScheme: colorScheme,
                        title: 'Autumn (C1)',
                        description:
                            'ระดับกลางค่อนข้างสูง เนื้อหาเชิงวิชาการ วิทยาศาสตร์ เทคโนโลยี การเมือง และธุรกิจ',
                        imagePath: 'assets/images/tree_6977585.png',
                        level: 'C1',
                      ),
                      const SizedBox(height: 20),

                      // Winter (C2)
                      _buildSeasonCard(
                        context: context,
                        colorScheme: colorScheme,
                        title: 'Winter (C2)',
                        description:
                            'ระดับสูง ศัพท์ที่ใช้ในการสื่อสารระดับเชี่ยวชาญ ปรัชญา การแพทย์ขั้นสูง กฎหมาย และวรรณกรรม',
                        imagePath: 'assets/images/tree_6977597.png',
                        level: 'C2',
                      ),
                      const SizedBox(height: 24),

                      // เปลี่ยนเป็นรูปแบบเดียวกันกับ Card ด้านบน
                      Card(
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: colorScheme.outlineVariant),
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
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'ทำไมแบ่งเป็นฤดู?',
                                    style: AppTextStyles.subtitle,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'แอปพลิเคชันของเราออกแบบให้การเรียนรู้เป็นเหมือนวงจรธรรมชาติ เริ่มจากระดับง่าย (Spring) ไปสู่ระดับที่ซับซ้อนมากขึ้น (Winter) เป็นเหมือนการเติบโตทางภาษาไปตามฤดูกาล เพื่อให้ง่ายต่อการจดจำและสร้างกระบวนการเรียนรู้ที่เป็นธรรมชาติ',
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
              const SizedBox(height: 20),
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
      ),
    );
  }

  Widget _buildSeasonCard({
    required BuildContext context,
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

    // ตรวจสอบขนาดหน้าจอเพื่อกำหนดโครงสร้าง UI
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600; // xs, sm

    Widget imageSection = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: colorScheme.surfaceVariant,
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                );
              },
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: levelColor.withOpacity(0.8),
                  borderRadius:
                      const BorderRadius.only(topLeft: Radius.circular(8)),
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
    );

    Widget contentSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.subtitle.copyWith(color: levelColor),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: AppTextStyles.body,
        ),
      ],
    );

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isSmallScreen
            // Layout for xs and sm screens (stacked)
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 120,
                    child: Center(child: imageSection),
                  ),
                  const SizedBox(height: 16),
                  contentSection,
                ],
              )
            // Layout for md and lg screens (side by side)
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: imageSection,
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: contentSection),
                ],
              ),
      ),
    );
  }
}
