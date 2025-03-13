import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import 'package:vocabtree/features/vocab/models/vocab_level_model.dart';
import 'package:vocabtree/features/vocab/services/vocab_service.dart';
import 'package:vocabtree/features/vocab/widgets/season_section.dart';

class VocabScreen extends StatefulWidget {
  const VocabScreen({super.key});

  @override
  VocabScreenState createState() => VocabScreenState();
}

class VocabScreenState extends State<VocabScreen> {
  final VocabService _vocabService = VocabService();
  String? userId;
  Map<String, Map<String, List<String>>> reviewWords =
      {}; // level -> topic -> wordsList
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
    _fetchAllReviewWords();
  }

  Future<void> _fetchAllReviewWords() async {
    setState(() => isLoading = true);

    try {
      if (userId != null) {
        reviewWords = await _vocabService.fetchAllReviewWords(
          userId!,
          VocabLevelModel.levelMapping,
        );
      }
    } catch (e) {
      // Silent error handling
    } finally {
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

    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text('คลังคำศัพท์', style: AppTextStyles.headline),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return _buildLoadingState();
    }

    return RefreshIndicator(
      onRefresh: _fetchAllReviewWords,
      color: Theme.of(context).colorScheme.primary,
      child: userId == null ? _buildNoUserContent() : _buildUserContent(),
    );
  }

  Widget _buildLoadingState() {
    return BootstrapContainer(
      fluid: true,
      children: [
        BootstrapRow(
          children: [
            BootstrapCol(
              sizes: 'col-12',
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'กำลังโหลดข้อมูลคำศัพท์...',
                      style: AppTextStyles.body,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoUserContent() {
    return BootstrapContainer(
      fluid: true,
      children: [
        BootstrapRow(
          children: [
            BootstrapCol(
              sizes: 'col-xs-12 col-sm-10 col-md-8 col-lg-6',
              offsets: 'offset-xs-0 offset-sm-1 offset-md-2 offset-lg-3',
              child: Card(
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
        ),
      ],
    );
  }

  Widget _buildUserContent() {
    final levels = VocabLevelModel.getAllLevels();

    return BootstrapContainer(
      fluid: true,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        BootstrapRow(
          children: [
            BootstrapCol(
              sizes: 'col-10',
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: levels.length,
                  itemBuilder: (context, index) {
                    return _buildLevelSection(levels[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLevelSection(VocabLevelModel level) {
    final levelTopics = reviewWords[level.level] ?? {};
    final topicsWithWords = level.topics
        .where((topic) => (levelTopics[topic]?.isNotEmpty) ?? false)
        .toList();

    if (topicsWithWords.isEmpty) {
      return const SizedBox.shrink();
    }

    return BootstrapRow(
      children: [
        BootstrapCol(
          sizes: 'col-xs-12 col-sm-12 col-md-10 col-lg-8',
          offsets: 'offset-xs-0 offset-sm-0 offset-md-1 offset-lg-2',
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
  }
}
