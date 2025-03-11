import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';

import '../../../core/theme/text_styles.dart';
import '../model/swipe_direction.dart';
import '../services/flashcard_service.dart';
import '../widgets/summary_statistics_widget.dart';
import '../widgets/unknown_words_section.dart';
import '../widgets/summary_action_buttons.dart';
import '../widgets/reset_confirmation_dialog.dart';

class FlashcardSummaryScreen extends StatefulWidget {
  final String userId;
  final String topic;
  final int knownCount;
  final int unknownCount;
  final int reviewCount;
  final int totalCount;
  final List<String> sessionUnknownWords;

  const FlashcardSummaryScreen({
    super.key,
    required this.userId,
    required this.topic,
    required this.knownCount,
    required this.unknownCount,
    required this.reviewCount,
    required this.totalCount,
    required this.sessionUnknownWords,
  });

  @override
  State<FlashcardSummaryScreen> createState() => _FlashcardSummaryScreenState();
}

class _FlashcardSummaryScreenState extends State<FlashcardSummaryScreen> {
  final FlashcardService _service = FlashcardService();
  bool _isResetting = false;
  List<String> _unknownWords = [];
  final Set<String> _selectedWords = {};
  bool _isAddingToBank = false;

  @override
  void initState() {
    super.initState();
    _loadUnknownWords();
  }

  // แก้ไขวิธีการโหลดคำศัพท์ที่ไม่รู้
  Future<void> _loadUnknownWords() async {
    try {
      // ใช้ Set เพื่อป้องกันคำซ้ำ
      Set<String> wordTexts = {};

      // แปลง ID เป็นคำศัพท์
      for (final wordId in widget.sessionUnknownWords) {
        try {
          final wordDetail = await _service.getWordDetail(wordId);
          if (wordDetail != null) {
            // เพิ่มคำลงใน Set ซึ่งจะเก็บเฉพาะคำที่ไม่ซ้ำกัน
            wordTexts.add(wordDetail.mainWord);
          } else {
            wordTexts.add(wordId); // ถ้าดึงข้อมูลไม่ได้ ให้ใช้ ID แทน
          }
        } catch (e) {
          wordTexts.add(wordId);
        }
      }

      setState(() {
        // แปลง Set เป็น List เพื่อใช้ในการแสดงผล
        _unknownWords = wordTexts.toList();
      });
    } catch (e) {
      debugPrint('Error loading unknown words: $e');
    }
  }

  void _toggleWordSelection(String word) {
    setState(() {
      if (_selectedWords.contains(word)) {
        _selectedWords.remove(word);
      } else {
        _selectedWords.add(word);
      }
    });
  }

  Future<void> _addSelectedWordsToBank() async {
    if (_selectedWords.isEmpty) return;

    setState(() {
      _isAddingToBank = true;
    });

    try {
      for (final word in _selectedWords) {
        await _service.saveWordStatus(
            widget.userId, widget.topic, word, SwipeDirection.up);
      }

      setState(() {
        _unknownWords.removeWhere((word) => _selectedWords.contains(word));
        _selectedWords.clear();
      });
    } catch (e) {
      debugPrint('Error adding words to bank: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToBank = false;
        });
      }
    }
  }

  Future<void> _confirmReset() async {
    final shouldReset = await ResetConfirmationDialog.show(context);

    if (shouldReset == true) {
      await _resetAllWords();
    }
  }

  Future<void> _resetAllWords() async {
    setState(() {
      _isResetting = true;
    });

    try {
      await _service.resetTopic(widget.userId, widget.topic);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      debugPrint("Error resetting words: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isResetting = false;
        });
      }
    }
  }

  void _restartFlashcards() {
    Navigator.pop(context);
  }

  String _formatTopicName(String topic) {
    return topic
        .split('_')
        .map(
            (w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    bootstrapGridParameters(gutterSize: 16);

    if (_isResetting) {
      return Scaffold(
        appBar: AppBar(
          title: Text('สรุปผลการเรียนรู้', style: AppTextStyles.headline),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: colorScheme.primary),
              const SizedBox(height: 16),
              Text('กำลังรีเซ็ตข้อมูล...', style: AppTextStyles.body),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('สรุปผลการเรียนรู้', style: AppTextStyles.headline),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: BootstrapContainer(
          fluid: true,
          children: [
            // หัวข้อและการแสดงผล
            const SizedBox(height: 20),

            BootstrapRow(
              children: [
                BootstrapCol(
                  sizes: 'col-xs-10 col-sm-10 col-md-8 col-lg-6',
                  offsets: 'offset-xs-1 offset-sm-1 offset-md-2 offset-lg-3',
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _formatTopicName(widget.topic),
                        style: AppTextStyles.title,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 70),

            // สถิติคำศัพท์
            BootstrapRow(
              children: [
                BootstrapCol(
                  sizes: 'col-xs-10 col-sm-10 col-md-8 col-lg-6',
                  offsets: 'offset-xs-1 offset-sm-1 offset-md-2 offset-lg-3',
                  child: SummaryStatisticsWidget(
                    totalCount: widget.totalCount,
                    knownCount: widget.knownCount,
                    unknownCount: widget.unknownCount,
                    reviewCount: widget.reviewCount,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 270),

            // คำศัพท์ที่ยังไม่รู้
            BootstrapRow(
              children: [
                BootstrapCol(
                  sizes: 'col-xs-10 col-sm-10 col-md-8 col-lg-6',
                  offsets: 'offset-xs-1 offset-sm-1 offset-md-2 offset-lg-3',
                  child: UnknownWordsSection(
                    unknownWords: _unknownWords,
                    selectedWords: _selectedWords,
                    onToggleWord: _toggleWordSelection,
                    onAddToBank: _addSelectedWordsToBank,
                    isAddingToBank: _isAddingToBank,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 100),

            // ปุ่มดำเนินการ
            BootstrapRow(
              children: [
                BootstrapCol(
                  sizes: 'col-xs-10 col-sm-10 col-md-8 col-lg-6',
                  offsets: 'offset-xs-1 offset-sm-1 offset-md-2 offset-lg-3',
                  child: SummaryActionButtons(
                    onRestart: _restartFlashcards,
                    onReset: _confirmReset,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
