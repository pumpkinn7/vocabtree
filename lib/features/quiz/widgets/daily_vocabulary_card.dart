import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import 'package:vocabtree/features/quiz/services/vocabulary_service.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:vocabtree/features/quiz/models/daily_vocabulary.dart';

class DailyVocabularyCard extends StatefulWidget {
  const DailyVocabularyCard({super.key});

  @override
  State<DailyVocabularyCard> createState() => _DailyVocabularyCardState();
}

class _DailyVocabularyCardState extends State<DailyVocabularyCard> {
  final VocabularyService _vocabularyService = VocabularyService();
  String _word = '';
  String _partOfSpeech = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRandomWord();
  }

  Future<void> _fetchRandomWord() async {
    setState(() => _isLoading = true);
    try {
      final vocabulary = await _vocabularyService.getRandomVocabulary();
      setState(() {
        _word = vocabulary?.word ?? 'ไม่พบคำศัพท์';
        _partOfSpeech = vocabulary?.type ?? '';
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _word = 'เกิดข้อผิดพลาดในการโหลดคำศัพท์';
        _isLoading = false;
      });
    }
  }

  Future<void> _openGoogleTranslate() async {
    final url =
        Uri.parse('https://translate.google.com/?sl=en&tl=th&text=$_word');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> _openCambridgeDictionary() async {
    final url =
        Uri.parse('https://dictionary.cambridge.org/dictionary/english/$_word');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : BootstrapContainer(
              fluid: true,
              padding: EdgeInsets.zero,
              children: [
                // Header
                BootstrapRow(
                  children: [
                    BootstrapCol(
                      sizes: 'col-xs-10 col-sm-10 col-md-8 col-lg-8',
                      offsets:
                          'offset-xs-1 offset-sm-1 offset-md-2 offset-lg-2',
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: Text(
                          'แนะนำคำศัพท์ประจำวัน',
                          style: AppTextStyles.subtitle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),

                // Content
                BootstrapRow(
                  children: [
                    // Animation
                    BootstrapCol(
                      sizes: 'col-xs-12 col-sm-12 col-md-6',
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Lottie.asset(
                          'assets/animations/Animation - 1741196193367.json',
                          height: 125,
                        ),
                      ),
                    ),
                    // Word Details
                    BootstrapCol(
                      sizes: 'col-xs-12 col-sm-12 col-md-6',
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_partOfSpeech.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _partOfSpeech,
                                  style: AppTextStyles.caption.copyWith(
                                    color: colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ),
                            Text(_word, style: AppTextStyles.headline),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Actions
                BootstrapRow(
                  children: [
                    BootstrapCol(
                      sizes: 'col-12',
                      child: ColoredBox(
                        color: colorScheme.surfaceVariant.withOpacity(0.6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _ActionButton(
                                onPressed: _openGoogleTranslate,
                                icon: Icons.translate,
                                label: 'Translate',
                                color: colorScheme.secondary,
                              ),
                              _ActionButton(
                                onPressed: _openCambridgeDictionary,
                                icon: Icons.menu_book,
                                label: 'Cambridge',
                                color: colorScheme.secondary,
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
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color color;

  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: AppTextStyles.caption.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class DailyVocabularyCardWithPreloadedData extends StatelessWidget {
  final DailyVocabulary? vocabulary;

  const DailyVocabularyCardWithPreloadedData({
    super.key,
    required this.vocabulary,
  });

  Future<void> _openGoogleTranslate(String word) async {
    final url =
        Uri.parse('https://translate.google.com/?sl=en&tl=th&text=$word');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> _openCambridgeDictionary(String word) async {
    final url =
        Uri.parse('https://dictionary.cambridge.org/dictionary/english/$word');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final word = vocabulary?.word ?? 'ไม่พบคำศัพท์';
    final partOfSpeech = vocabulary?.type ?? '';

    return Card(
      margin: EdgeInsets.zero,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: BootstrapContainer(
        fluid: true,
        padding: EdgeInsets.zero,
        children: [
          // Header
          BootstrapRow(
            children: [
              BootstrapCol(
                sizes: 'col-xs-10 col-sm-10 col-md-8 col-lg-8',
                offsets: 'offset-xs-1 offset-sm-1 offset-md-2 offset-lg-2',
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: Text(
                    'แนะนำคำศัพท์ประจำวัน',
                    style: AppTextStyles.subtitle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),

          // Content
          BootstrapRow(
            children: [
              // Animation
              BootstrapCol(
                sizes: 'col-xs-12 col-sm-12 col-md-6',
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Lottie.asset(
                    'assets/animations/Animation - 1741196193367.json',
                    height: 125,
                  ),
                ),
              ),
              // Word Details
              BootstrapCol(
                sizes: 'col-xs-12 col-sm-12 col-md-6',
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (partOfSpeech.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            partOfSpeech,
                            style: AppTextStyles.caption.copyWith(
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      Text(word, style: AppTextStyles.headline),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Actions
          BootstrapRow(
            children: [
              BootstrapCol(
                sizes: 'col-12',
                child: ColoredBox(
                  color: colorScheme.surfaceVariant.withOpacity(0.6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ActionButton(
                          onPressed: () => _openGoogleTranslate(word),
                          icon: Icons.translate,
                          label: 'Translate',
                          color: colorScheme.secondary,
                        ),
                        _ActionButton(
                          onPressed: () => _openCambridgeDictionary(word),
                          icon: Icons.menu_book,
                          label: 'Cambridge',
                          color: colorScheme.secondary,
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
    );
  }
}
