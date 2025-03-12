import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import '../../../core/theme/text_styles.dart';

class FlashcardHelpDialog extends StatelessWidget {
  const FlashcardHelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ส่วนหัวข้อที่อยู่คงที่
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            width: double.infinity,
            child: Text(
              'วิธีใช้งานฟลัชการ์ด',
              style: AppTextStyles.title.copyWith(
                color: colorScheme.primary,
              ),
            ),
          ),

          // ส่วนเนื้อหาที่สามารถเลื่อนได้
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: BootstrapContainer(
                  fluid: true,
                  children: [
                    BootstrapRow(
                      children: [
                        BootstrapCol(
                          sizes: 'col-12',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildHelpItem(
                                context,
                                'assets/images/Flashcard-1.png',
                                'ปัดซ้าย / ไม่รู้จัก',
                                'ใช้เมื่อคุณยังไม่รู้จักคำศัพท์นี้ ระบบจะนำคำศัพท์นี้ไปอยู่ในกลุ่ม "ยังไม่รู้จัก"',
                                colorScheme,
                              ),
                              _buildHelpItem(
                                context,
                                'assets/images/Flashcard-2.png',
                                'อ่านออกเสียง',
                                'ฟังการออกเสียงของคำศัพท์นี้ เพื่อช่วยในการจดจำและการออกเสียงที่ถูกต้อง',
                                colorScheme,
                              ),
                              _buildHelpItem(
                                context,
                                'assets/images/Flashcard-3.png',
                                'ปัดขึ้น / ต้องทบทวน',
                                'ใช้เมื่อคุณพอรู้จักคำศัพท์นี้แต่ยังต้องการทบทวนในภายหลัง ระบบจะนำคำศัพท์นี้ไปอยู่ในกลุ่ม "ต้องทบทวน"',
                                colorScheme,
                              ),
                              _buildHelpItem(
                                context,
                                'assets/images/Flashcard-4.png',
                                'แปลภาษา',
                                'แปลคำศัพท์เป็นภาษาไทย หรือแสดงความหมายของคำศัพท์ เพื่อให้เข้าใจความหมายได้ง่ายขึ้น',
                                colorScheme,
                              ),
                              _buildHelpItem(
                                context,
                                'assets/images/Flashcard-5.png',
                                'ปัดขวา / รู้จักแล้ว',
                                'ใช้เมื่อคุณรู้จักคำศัพท์นี้ดีแล้ว ระบบจะนำคำศัพท์นี้ไปอยู่ในกลุ่ม "รู้จักแล้ว"',
                                colorScheme,
                                isLast: true,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'เคล็ดลับ: คุณสามารถกดปุ่ม "i" ที่มุมขวาบนของการ์ดเพื่อดูรายละเอียดเพิ่มเติมของคำศัพท์ได้',
                                style: AppTextStyles.body.copyWith(
                                  color: colorScheme.primary,
                                  fontStyle: FontStyle.italic,
                                ),
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
          ),

          // ปุ่มด้านล่าง
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'เข้าใจแล้ว',
                style: AppTextStyles.buttonText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(
    BuildContext context,
    String imagePath,
    String title,
    String description,
    ColorScheme colorScheme, {
    bool isLast = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BootstrapRow(
          children: [
            BootstrapCol(
              sizes: 'col-3 col-md-2',
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  imagePath,
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            BootstrapCol(
              sizes: 'col-9 col-md-10',
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.subtitle.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.body.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (!isLast)
          Divider(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            height: 24,
          ),
      ],
    );
  }
}
