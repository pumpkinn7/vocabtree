import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import 'package:vocabtree/features/vocab/models/vocab_level_model.dart';
import 'package:vocabtree/features/vocab/services/vocab_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // ตัวแปรสำหรับเก็บตัวกรองที่เลือก
  final _selectedCefrLevels = <String>{};
  final _selectedTopics = <String>{};
  bool _onlySavedWords = false;

  // รายการตัวเลือกคงที่
  final _allCefrLevels = ['B1', 'B2', 'C1', 'C2'];

  // ข้อมูล Topic ทั้งหมดตามระดับ
  final Map<String, List<String>> _topicsByLevel = {};

  @override
  void initState() {
    super.initState();
    _initializeTopics();
  }

  void _initializeTopics() {
    // ดึงข้อมูล topic ตามระดับจาก VocabLevelModel
    for (var level in _allCefrLevels) {
      _topicsByLevel[level] = VocabLevelModel.levelMapping[level] ?? [];
    }
  }

  void _applyFilters() {
    // สร้าง Filter Model เพื่อส่งกลับไปยังหน้าก่อนหน้า
    final filterParams = {
      'cefrLevels': _selectedCefrLevels.toList(),
      'topics': _selectedTopics.toList(),
      'onlySavedWords': _onlySavedWords,
    };

    Navigator.pop(context, filterParams);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('ตัวกรองคำศัพท์', style: AppTextStyles.headline),
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                _selectedCefrLevels.clear();
                _selectedTopics.clear();
                _onlySavedWords = false;
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

                    // ส่วนหมวดหมู่
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

                    // ส่วนการแสดงเฉพาะคำที่บันทึก
                    if (FirebaseAuth.instance.currentUser != null)
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: _buildSavedWordsFilter(),
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

  Widget _buildSavedWordsFilter() {
    return SwitchListTile(
      title: Text('แสดงเฉพาะคำที่บันทึกไว้', style: AppTextStyles.body),
      subtitle: Text(
        'แสดงเฉพาะคำศัพท์ที่คุณได้บันทึกไว้เพื่อทบทวน',
        style: AppTextStyles.caption,
      ),
      value: _onlySavedWords,
      onChanged: (value) {
        setState(() {
          _onlySavedWords = value;
        });
      },
      activeColor: Theme.of(context).colorScheme.primary,
    );
  }
}
