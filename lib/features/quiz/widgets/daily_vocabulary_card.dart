import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_tts/flutter_tts.dart';
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
  final FlutterTts _flutterTts = FlutterTts();
  final VocabularyService _vocabularyService = VocabularyService();
  String _word = '';
  String _definition = '';
  String _partOfSpeech = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _flutterTts.setLanguage("en-US");
    _fetchRandomWord();
  }

  Future<void> _fetchRandomWord() async {
    setState(() => _isLoading = true);

    try {
      final vocabulary = await _vocabularyService.getRandomVocabulary();
      setState(() {
        _word = vocabulary?.word ?? 'ไม่พบคำศัพท์';
        _definition = vocabulary?.definition ?? '';
        _partOfSpeech = vocabulary?.type ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _word = 'เกิดข้อผิดพลาดในการโหลดคำศัพท์';
        _definition = '';
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Card(
        elevation: 2,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const SizedBox(
          height: 200,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: BootstrapContainer(
        fluid: true,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        children: [
          // Header
          BootstrapRow(
            children: [
              BootstrapCol(
                sizes: 'col-12',
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_stories_rounded,
                          color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Text('คำศัพท์ประจำวัน', style: AppTextStyles.subtitle),
                      const Spacer(),
                      IconButton(
                        onPressed: _fetchRandomWord,
                        icon: const Icon(Icons.refresh_rounded),
                        tooltip: 'สุ่มคำใหม่',
                      ),
                    ],
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
                sizes: 'col-12 col-md-4',
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 160,
                    child: Lottie.asset(
                      'assets/animations/Animation - 1741196193367.json',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              // Word Details
              BootstrapCol(
                sizes: 'col-12 col-md-8',
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _word,
                        style: AppTextStyles.title.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_partOfSpeech.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                colorScheme.primaryContainer.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(_partOfSpeech,
                              style: AppTextStyles.body.copyWith(
                                color: colorScheme.primary,
                                fontStyle: FontStyle.italic,
                              )),
                        ),
                      ],
                      if (_definition.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          _definition,
                          style: AppTextStyles.body.copyWith(height: 1.5),
                        ),
                      ],
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
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton.filled(
                        onPressed: () => _flutterTts.speak(_word),
                        icon: const Icon(Icons.volume_up),
                        tooltip: 'ฟังเสียง',
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _openGoogleTranslate,
                        icon: const Icon(Icons.translate),
                        tooltip: 'แปลด้วย Google',
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _openCambridgeDictionary,
                        icon: const Icon(Icons.menu_book),
                        tooltip: 'Cambridge Dictionary',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
