import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import 'package:vocabtree/features/vocab/services/vocab_service.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final _selectedCefrLevels = <String>{};
  final _selectedTopics = <String>{};
  final _selectedPartOfSpeech = <String>{};

  final _allCefrLevels = ['B1', 'B2', 'C1', 'C2'];
  final _allPartOfSpeech = [
    'noun',
    'verb',
    'adjective',
    'adverb',
    'pronoun',
    'preposition',
    'conjunction',
    'interjection'
  ];

  final Map<String, List<String>> _topicsByLevel = {};

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTopics();
  }

  Future<void> _fetchTopics() async {
    try {
      setState(() => _isLoading = true);

      final firestore = FirebaseFirestore.instance;

      for (var level in _allCefrLevels) {
        final snapshot = await firestore
            .collection('word_categories')
            .where('cefrLevel', isEqualTo: level)
            .get();

        final topics = snapshot.docs.map((doc) => doc.id).toList();

        _topicsByLevel[level] = topics;
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'ไม่สามารถโหลดข้อมูลได้ กรุณาลองใหม่อีกครั้ง';
      });
    }
  }

  void _applyFilters() {
    if (_selectedCefrLevels.isEmpty &&
        _selectedTopics.isEmpty &&
        _selectedPartOfSpeech.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final filterParams = {
      'cefrLevels': _selectedCefrLevels.toList(),
      'topics': _selectedTopics.toList(),
      'partOfSpeech':
          _selectedPartOfSpeech.toList(), // เพิ่มประเภทของคำในพารามิเตอร์
    };

    Navigator.pop(context, filterParams);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('ตัวกรองคำศัพท์', style: AppTextStyles.headline),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('ตัวกรองคำศัพท์', style: AppTextStyles.headline),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: AppTextStyles.body),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchTopics,
                child: const Text('ลองใหม่'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('ตัวกรองคำศัพท์', style: AppTextStyles.headline),
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                _selectedCefrLevels.clear();
                _selectedTopics.clear();
                _selectedPartOfSpeech.clear(); // เพิ่มการล้างตัวกรองประเภทของคำ
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('รีเซ็ต'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ส่วนระดับ CEFR
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.school, color: colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'ระดับ CEFR',
                                  style: AppTextStyles.subtitle,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildCefrLevelFilter(),
                          ],
                        ),
                      ),
                    ),

                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.category,
                                    color: colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'หมวดหมู่',
                                  style: AppTextStyles.subtitle,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildTopicsFilter(),
                          ],
                        ),
                      ),
                    ),

                    // เพิ่มส่วนกรองประเภทของคำ (parts of speech)
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.type_specimen,
                                    color: colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'ประเภทของคำ',
                                  style: AppTextStyles.subtitle,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildPartOfSpeechFilter(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ปุ่มนำไปใช้
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'นำไปใช้',
                  style: AppTextStyles.buttonText.copyWith(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCefrLevelFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _allCefrLevels.map((level) {
        final selected = _selectedCefrLevels.contains(level);
        return ChoiceChip(
          label: Text(level),
          selected: selected,
          onSelected: (value) {
            setState(() {
              if (value) {
                _selectedCefrLevels.add(level);
              } else {
                _selectedCefrLevels.remove(level);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildTopicsFilter() {
    if (_selectedCefrLevels.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(Icons.arrow_upward, size: 32),
              const SizedBox(height: 8),
              Text(
                'กรุณาเลือกระดับ CEFR ก่อน',
                style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _selectedCefrLevels.map((level) {
        final topics = _topicsByLevel[level] ?? [];

        if (topics.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'ระดับ $level',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: topics.map((topic) {
                final selected = _selectedTopics.contains(topic);
                final formattedTopic = VocabService.formatTopicName(topic);
                return FilterChip(
                  label: Text(
                    formattedTopic,
                    style: TextStyle(
                      fontSize: 13,
                      color: selected ? Colors.white : null,
                    ),
                  ),
                  selected: selected,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        _selectedTopics.add(topic);
                      } else {
                        _selectedTopics.remove(topic);
                      }
                    });
                  },
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  checkmarkColor: Colors.white,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  // เพิ่มวิดเจ็ตแสดงตัวกรองประเภทของคำ
  Widget _buildPartOfSpeechFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _allPartOfSpeech.map((pos) {
        final selected = _selectedPartOfSpeech.contains(pos);
        return FilterChip(
          label: Text(
            _formatPartOfSpeech(pos),
            style: TextStyle(
              fontSize: 13,
              color: selected ? Colors.white : null,
            ),
          ),
          selected: selected,
          onSelected: (value) {
            setState(() {
              if (value) {
                _selectedPartOfSpeech.add(pos);
              } else {
                _selectedPartOfSpeech.remove(pos);
              }
            });
          },
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          selectedColor: Theme.of(context).colorScheme.primary,
          checkmarkColor: Colors.white,
        );
      }).toList(),
    );
  }

  String _formatPartOfSpeech(String pos) {
    final Map<String, String> posTranslation = {
      'noun': 'คำนาม',
      'verb': 'คำกริยา',
      'adjective': 'คำคุณศัพท์',
      'adverb': 'คำวิเศษณ์',
      'pronoun': 'คำสรรพนาม',
      'preposition': 'คำบุพบท',
      'conjunction': 'คำสันธาน',
      'interjection': 'คำอุทาน',
    };

    return posTranslation[pos] ?? pos;
  }
}
