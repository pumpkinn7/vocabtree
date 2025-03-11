import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import 'package:vocabtree/features/quiz/services/result_service.dart';

class AllWrongWordsDialog extends StatelessWidget {
  final String userId;
  final String topic;

  const AllWrongWordsDialog({
    super.key,
    required this.userId,
    required this.topic,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text('คำศัพท์ที่ตอบผิดทั้งหมด', style: AppTextStyles.headline),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: colorScheme.surface,
          elevation: 0,
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: ResultService.getTopWrongWords(
            userId,
            limit: 100,
            topic: topic,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'กำลังโหลดข้อมูล...',
                      style: AppTextStyles.body,
                    ),
                  ],
                ),
              );
            }

            final words = snapshot.data ?? [];

            if (words.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: colorScheme.primary,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ไม่พบประวัติคำศัพท์ที่ตอบผิด',
                      style: AppTextStyles.subtitle,
                    ),
                  ],
                ),
              );
            }

            return BootstrapContainer(
              fluid: true,
              padding: const EdgeInsets.all(16.0),
              children: [
                BootstrapRow(
                  children: [
                    BootstrapCol(
                      sizes: 'col-12',
                      child: Card(
                        elevation: 0,
                        color: colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: colorScheme.outlineVariant.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: words.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: colorScheme.outlineVariant.withOpacity(0.3),
                            indent: 16,
                            endIndent: 16,
                          ),
                          itemBuilder: (context, index) {
                            final word = words[index];
                            return ListTile(
                              title: Text(
                                word['word'],
                                style: AppTextStyles.body
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'ระดับ: ${word['cefr'] ?? 'ไม่ระบุ'}',
                                style: AppTextStyles.caption,
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: colorScheme.errorContainer,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'ตอบผิด ${word['wrongCount']} ครั้ง',
                                  style: AppTextStyles.caption.copyWith(
                                    color: colorScheme.onErrorContainer,
                                  ),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
