import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import 'package:vocabtree/features/vocab/models/vocab_level_model.dart';
import 'package:vocabtree/features/vocab/services/vocab_service.dart';
import 'package:vocabtree/features/vocab/widgets/empty_vocab_state.dart';
import 'package:vocabtree/features/vocab/widgets/season_section.dart';
import '../widgets/vocab_loading.dart';

class VocabScreen extends StatefulWidget {
  const VocabScreen({super.key});

  @override
  VocabScreenState createState() => VocabScreenState();
}

class VocabScreenState extends State<VocabScreen> {
  final VocabService _vocabService = VocabService();
  String? userId;
  Map<String, Map<String, List<String>>> reviewWords = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
    _fetchAllReviewWords();
  }

  Future<void> _fetchAllReviewWords() async {
    setState(() => isLoading = true);
    final startTime = DateTime.now();

    try {
      if (userId != null) {
        reviewWords = await _vocabService.fetchAllReviewWords(
            userId!, VocabLevelModel.levelMapping);
      }
    } catch (e) {
      // Silent error handling
    }

    final elapsedTime = DateTime.now().difference(startTime).inMilliseconds;
    final minimumLoadingTime = 3500;

    if (elapsedTime < minimumLoadingTime) {
      await Future.delayed(
        Duration(milliseconds: minimumLoadingTime - elapsedTime),
      );
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  void _removeFromReviewWords(String level, String topic, String word) async {
    if (userId == null) return;

    try {
      await _vocabService.removeFromReviewWords(userId!, topic, word);

      setState(() {
        reviewWords[level]![topic]?.remove(word);
      });
    } catch (_) {}
  }

  void _showCompletionMessage(String topic) {
    // ฟังก์ชันว่าง
  }

  @override
  Widget build(BuildContext context) {
    bootstrapGridParameters(gutterSize: 16);

    if (isLoading) {
      return const Scaffold(
        body: VocabLoading(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('คลังคำศัพท์', style: AppTextStyles.headline),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAllReviewWords,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: BootstrapContainer(
            fluid: true,
            padding: const EdgeInsets.all(16),
            children: [
              if (isLoading)
                BootstrapRow(
                  children: [
                    BootstrapCol(
                      sizes: 'col-12',
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ],
                )
              else if (userId == null)
                BootstrapRow(
                  children: [
                    BootstrapCol(
                      sizes: 'col-xs-12 col-sm-12 col-md-10 col-lg-8',
                      offsets:
                          'offset-xs-0 offset-sm-0 offset-md-1 offset-lg-2',
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Icon(
                                Icons.account_circle_outlined,
                                size: 64,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'กรุณาเข้าสู่ระบบเพื่อดูคลังคำศัพท์ของคุณ',
                                style: AppTextStyles.subtitle,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else if (_hasNoReviewWords())
                const EmptyVocabState()
              else
                ...VocabLevelModel.getAllLevels().map((level) {
                  final levelTopics = reviewWords[level.level] ?? {};
                  final topicsWithWords = level.topics
                      .where(
                          (topic) => (levelTopics[topic]?.isNotEmpty) ?? false)
                      .toList();

                  if (topicsWithWords.isEmpty) return const SizedBox.shrink();

                  return BootstrapRow(
                    children: [
                      BootstrapCol(
                        sizes: 'col-xs-12 col-sm-12 col-md-8 col-lg-6',
                        offsets:
                            'offset-xs-0 offset-sm-0 offset-md-2 offset-lg-3',
                        child: SeasonSection(
                          level: level.level,
                          topics: topicsWithWords,
                          reviewWords: levelTopics,
                          userId: userId!,
                          onRemoveWord: _removeFromReviewWords,
                          onShowCompletionMessage: _showCompletionMessage,
                          onRefreshData: _fetchAllReviewWords,
                        ),
                      ),
                    ],
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasNoReviewWords() {
    if (reviewWords.isEmpty) return true;

    for (var levelTopics in reviewWords.values) {
      for (var words in levelTopics.values) {
        if (words.isNotEmpty) return false;
      }
    }

    return true;
  }
}
