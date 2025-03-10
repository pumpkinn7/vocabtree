import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import 'package:vocabtree/features/quiz/services/vocabulary_service.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';

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
    } catch (e) {
      setState(() {
        _word = 'เกิดข้อผิดพลาดในการโหลดคำศัพท์';
        _partOfSpeech = '';
        _isLoading = false;
      });
    }
  }

  Future<void> _openGoogleTranslate() async {
    final url =
        Uri.parse('https://translate.google.com/?sl=en&tl=th&text=$_word');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openCambridgeDictionary() async {
    final url =
        Uri.parse('https://dictionary.cambridge.org/dictionary/english/$_word');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Card(
        margin: EdgeInsets.zero,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 3,
      surfaceTintColor: colorScheme.primary,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: BootstrapContainer(
        fluid: true,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.surfaceVariant.withOpacity(0.5),
            ],
          ),
        ),
        children: [
          // Header
          BootstrapRow(
            children: [
              BootstrapCol(
                sizes: 'col-12',
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
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
              // Animation Column
              BootstrapCol(
                sizes: 'col-xs-12 col-sm-12 col-md-6',
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Lottie.asset(
                      'assets/animations/Animation - 1741196193367.json',
                      fit: BoxFit.contain,
                      height: 125,
                    ),
                  ),
                ),
              ),
              _buildWordDetails(colorScheme),
            ],
          ),

          // Action Bar
          BootstrapRow(
            children: [
              BootstrapCol(
                sizes: 'col-12',
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.6),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: _buildToolButtons(colorScheme),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartOfSpeech(ColorScheme colorScheme) {
    if (_partOfSpeech.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    );
  }

  BootstrapCol _buildWordDetails(ColorScheme colorScheme) {
    // เปลี่ยนจาก Widget เป็น BootstrapCol
    return BootstrapCol(
      sizes: 'col-xs-12 col-sm-12 col-md-6',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPartOfSpeech(colorScheme),
            Text(
              _word,
              style: AppTextStyles.headline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButtons(ColorScheme colorScheme) {
    final buttonColor = colorScheme.secondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.6),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            onPressed: _openGoogleTranslate,
            icon: Icons.translate,
            label: 'Google Translate',
            color: buttonColor,
          ),
          _buildActionButton(
            onPressed: _openCambridgeDictionary,
            icon: Icons.menu_book,
            label: 'Cambridge',
            color: buttonColor,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
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
            Text(
              label,
              style: AppTextStyles.caption.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
