import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import 'package:vocabtree/features/flashcards/screens/flashcard_topic_screen.dart';
import 'package:vocabtree/features/quiz/screens/quiz_topic_screen.dart';
import 'package:vocabtree/features/quiz/services/cefr_level_service.dart';
import 'package:vocabtree/features/quiz/widgets/cefr_timeline.dart';
import 'package:vocabtree/features/quiz/models/topic_model.dart';

class CefrLevelScreen extends StatefulWidget {
  final String cefrLevel;
  final String userId;

  const CefrLevelScreen({
    super.key,
    required this.cefrLevel,
    required this.userId,
  });

  @override
  State<CefrLevelScreen> createState() => _CefrLevelScreenState();
}

class _CefrLevelScreenState extends State<CefrLevelScreen> {
  // นำทางไปหน้า Flashcard
  void _navigateToFlashcards(String topicId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlashcardScreen(
          topic: topicId,
          userId: widget.userId,
        ),
      ),
    );
  }

  // นำทางไปหน้า Quiz
  void _navigateToQuiz(String topicId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizTopicScreen(
          topic: topicId,
          cefrLevel: widget.cefrLevel,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    bootstrapGridParameters(gutterSize: 16);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return FutureBuilder<Map<String, dynamic>>(
      future: CefrLevelService.fetchCefrLevelData(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return _buildTopicsList(snapshot.data);
      },
    );
  }

  Widget _buildTopicsList(Map<String, dynamic>? data) {
    final Map<String, dynamic> dataMap = data ?? {};
    final unlockedTopics =
        dataMap['unlockedTopics'] as Map<String, dynamic>? ?? {};
    final topicImages = dataMap['topicImages'] as Map<String, String>? ?? {};
    final List<TopicModel> topics = CefrLevelService.getTopicModels(
      widget.cefrLevel,
      unlockedTopics,
      topicImages,
    );

    final Map<String, Map<String, dynamic>> seasonTheme = {
      'B1': {
        'icon': Icons.local_florist,
        'iconColor': Colors.green[400],
        'image': 'assets/images/spring.png',
        'description': 'Spring - ระดับพื้นฐานถึงปานกลาง',
      },
      'B2': {
        'icon': Icons.wb_sunny,
        'iconColor': Colors.amber[600],
        'image': 'assets/images/summer.png',
        'description': 'Summer - ระดับปานกลาง',
      },
      'C1': {
        'icon': Icons.eco,
        'iconColor': Colors.deepOrange[400],
        'image': 'assets/images/autumn.png',
        'description': 'Autumn - ระดับกลางค่อนข้างสูง',
      },
      'C2': {
        'icon': Icons.ac_unit,
        'iconColor': Colors.blueGrey[400],
        'image': 'assets/images/winter.png',
        'description': 'Winter - ระดับสูง',
      },
    };

    final theme = seasonTheme[widget.cefrLevel] ?? seasonTheme['B1']!;

    return SingleChildScrollView(
      child: BootstrapContainer(
        fluid: true,
        padding: const EdgeInsets.all(16),
        children: [
          BootstrapRow(
            children: [
              BootstrapCol(
                sizes: 'col-xs-12 col-sm-12 col-md-6 col-lg-6 col-xl-6',
                offsets:
                    'offset-xs-0 offset-sm-0 offset-md-3 offset-lg-3 offset-xl-3',
                child: _buildSeasonBanner(theme),
              ),
            ],
          ),
          BootstrapRow(
            children: [
              BootstrapCol(
                sizes: 'col-xs-12 col-sm-12 col-md-6 col-lg-6 col-xl-6',
                offsets:
                    'offset-xs-0 offset-sm-0 offset-md-3 offset-lg-3 offset-xl-3',
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: CefrTimeline(
                    topics: topics,
                    onFlashcardTap: _navigateToFlashcards,
                    onQuizTap: _navigateToQuiz,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonBanner(Map<String, dynamic> theme) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // ภาพพื้นหลัง
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  theme['image'],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // เนื้อหา
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      theme['icon'] as IconData,
                      color: theme['iconColor'] as Color?,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'CEFR ${widget.cefrLevel}',
                      style: AppTextStyles.subtitle,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  theme['description'],
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
