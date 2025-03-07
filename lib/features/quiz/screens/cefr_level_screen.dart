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
      appBar: _buildAppBar(),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  // สร้าง App Bar แบบ Material Design 3
  PreferredSizeWidget _buildAppBar() {
    final seasonTitle = CefrLevelService.getSeasonTitle(widget.cefrLevel);
    return AppBar(
      title: Text(
        seasonTitle,
        style: AppTextStyles.title,
      ),
      scrolledUnderElevation: 0.0,
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline),
          tooltip: 'ช่วยเหลือ',
          onPressed: () => _showCefrLevelInfo(context),
        ),
      ],
    );
  }

  // แสดงข้อมูลเกี่ยวกับระดับ CEFR
  void _showCefrLevelInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildCefrInfoSheet(),
    );
  }

  // สร้าง Bottom Sheet สำหรับแสดงข้อมูล CEFR
  Widget _buildCefrInfoSheet() {
    Map<String, String> cefrInfo = {
      'B1': 'สามารถเข้าใจจุดสำคัญของข้อความที่ชัดเจนในเรื่องที่คุ้นเคย',
      'B2': 'สามารถเข้าใจใจความสำคัญของบทความที่ซับซ้อนได้',
      'C1': 'สามารถเข้าใจข้อความยาวๆ และซับซ้อนได้',
      'C2': 'สามารถเข้าใจทุกสิ่งที่อ่านหรือได้ยินได้โดยง่าย',
    };

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      expand: false,
      builder: (_, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
                margin: const EdgeInsets.only(bottom: 20),
              ),
            ),
            Text(
              'ระดับภาษาอังกฤษ CEFR',
              style: AppTextStyles.headline,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'ระดับ ${widget.cefrLevel}: ${cefrInfo[widget.cefrLevel] ?? ""}',
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 16),
            const Text(
              'CEFR คือ กรอบอ้างอิงความสามารถทางภาษาของสหภาพยุโรป (Common European Framework of Reference for Languages) เป็นมาตรฐานที่ใช้อธิบายระดับความสามารถทางภาษาต่างประเทศ',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // แยกส่วนการสร้าง body เป็นเมธอดแยกเพื่อความชัดเจน
  Widget _buildBody() {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return FutureBuilder<Map<String, dynamic>>(
      future: CefrLevelService.fetchCefrLevelData(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingView();
        }

        if (snapshot.hasError) {
          return _buildErrorView();
        }

        return _buildTopicsList(snapshot.data);
      },
    );
  }

  // แสดงหน้า error กรณีโหลดข้อมูลไม่สำเร็จ
  Widget _buildErrorView() {
    return Center(
      child: BootstrapCol(
        sizes: 'col-md-6 col-12',
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                Text(
                  'เกิดข้อผิดพลาดในการโหลดข้อมูล',
                  style: AppTextStyles.subtitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'โปรดลองใหม่อีกครั้ง',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => setState(() {}),
                  icon: const Icon(Icons.refresh),
                  label: const Text('ลองอีกครั้ง'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ปรับปรุง Loading View ให้สวยงามขึ้น
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'กำลังโหลดข้อมูล...',
            style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'โปรดรอสักครู่',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  // สร้าง Widget แสดงรายการหัวข้อ
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
        'color': Colors.green[50],
        'icon': Icons.local_florist,
        'image': 'assets/images/spring.png',
        'description': 'Spring - ระดับพื้นฐานถึงปานกลาง',
      },
      'B2': {
        'color': Colors.amber[50],
        'icon': Icons.wb_sunny,
        'image': 'assets/images/summer.png',
        'description': 'Summer - ระดับปานกลาง',
      },
      'C1': {
        'color': Colors.orange[50],
        'icon': Icons.eco,
        'image': 'assets/images/autumn.png',
        'description': 'Autumn - ระดับกลางค่อนข้างสูง',
      },
      'C2': {
        'color': Colors.lightBlue[50],
        'icon': Icons.ac_unit,
        'image': 'assets/images/winter.png',
        'description': 'Winter - ระดับสูง',
      },
    };

    final theme = seasonTheme[widget.cefrLevel] ?? seasonTheme['B1']!;

    return SingleChildScrollView(
      child: BootstrapContainer(
        fluid: true,
        children: [
          BootstrapRow(
            children: [
              BootstrapCol(
                sizes: 'col-12',
                child: _buildSeasonBanner(theme),
              ),
            ],
          ),
          BootstrapRow(
            children: [
              BootstrapCol(
                sizes: 'col-lg-8 col-md-10 col-12 offset-lg-2 offset-md-1',
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

  // สร้าง Banner แสดงฤดูกาล
  Widget _buildSeasonBanner(Map<String, dynamic> theme) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 0,
      color: theme['color'],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BootstrapRow(
          children: [
            BootstrapCol(
              sizes: 'col-md-8 col-12',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(theme['icon'],
                          size: 28, color: AppTextStyles.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'CEFR ${widget.cefrLevel}',
                        style: AppTextStyles.subtitle.copyWith(
                          color: AppTextStyles.primaryDarkColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    theme['description'],
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ผ่านการทดสอบคำศัพท์ในระดับนี้เพื่อปลดล็อคหัวข้อถัดไป',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            BootstrapCol(
              sizes: 'col-md-4 col-12 d-none d-md-block',
              child: Image.asset(
                theme['image'],
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  theme['icon'],
                  size: 80,
                  color: AppTextStyles.primaryColor.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
