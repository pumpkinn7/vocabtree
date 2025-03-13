import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:vocabtree/features/vocab/widgets/season_header.dart';
import 'package:vocabtree/features/vocab/widgets/topic_card.dart';

class SeasonSection extends StatelessWidget {
  final String level;
  final List<String> topics;
  final Map<String, List<String>> reviewWords;
  final String userId;
  final Function(String, String, String) onRemoveWord;
  final Function(String) onShowCompletionMessage;
  final Function() onRefreshData;

  // ข้อมูลฤดูกาลตามระดับ CEFR
  static final Map<String, Map<String, dynamic>> seasonTheme = {
    'B1': {
      'icon': Icons.local_florist,
      'iconColor': Colors.green[400],
      'image': 'assets/images/spring.png',
      'description': 'Spring - ระดับพื้นฐานถึงปานกลาง',
      'name': 'SPRING',
    },
    'B2': {
      'icon': Icons.wb_sunny,
      'iconColor': Colors.amber[600],
      'image': 'assets/images/summer.png',
      'description': 'Summer - ระดับปานกลาง',
      'name': 'SUMMER',
    },
    'C1': {
      'icon': Icons.eco,
      'iconColor': Colors.deepOrange[400],
      'image': 'assets/images/autumn.png',
      'description': 'Autumn - ระดับกลางค่อนข้างสูง',
      'name': 'AUTUMN',
    },
    'C2': {
      'icon': Icons.ac_unit,
      'iconColor': Colors.blueGrey[400],
      'image': 'assets/images/winter.png',
      'description': 'Winter - ระดับสูง',
      'name': 'WINTER',
    },
  };

  const SeasonSection({
    super.key,
    required this.level,
    required this.topics,
    required this.reviewWords,
    required this.userId,
    required this.onRemoveWord,
    required this.onShowCompletionMessage,
    required this.onRefreshData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = seasonTheme[level] ?? seasonTheme['B1']!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // หัวข้อฤดูกาล
        _buildSeasonHeader(theme),

        // แสดงเนื้อหาตาม topic
        _buildTopicsGrid(context, theme),
      ],
    );
  }

  Widget _buildSeasonHeader(Map<String, dynamic> theme) {
    return SeasonHeader(
      icon: theme['icon'],
      iconColor: theme['iconColor'],
      seasonName: theme['name'],
      description: theme['description'],
      backgroundImage: theme['image'],
    );
  }

  Widget _buildTopicsGrid(BuildContext context, Map<String, dynamic> theme) {
    return BootstrapContainer(
      fluid: true,
      padding: EdgeInsets.zero,
      children: [
        BootstrapRow(
          children: [
            BootstrapCol(
              sizes: 'col-xs-12 col-sm-12 col-md-10 col-lg-8',
              offsets: 'offset-xs-0 offset-sm-0 offset-md-1 offset-lg-2',
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children:
                      topics.map((topic) => _buildTopicCard(topic)).toList(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopicCard(String topic) {
    return TopicCard(
      topic: topic,
      wordsList: reviewWords[topic] ?? [],
      level: level,
      userId: userId,
      onRemoveWord: onRemoveWord,
      onShowCompletionMessage: onShowCompletionMessage,
      onRefreshData: onRefreshData,
    );
  }
}
