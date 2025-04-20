import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import '../services/dictionary_service.dart';
import '../widgets/dictionary_search_bar.dart';
import '../widgets/topic_word_list_section.dart';
import '../widgets/vocab_detail_with_add_dialog.dart';

class AllVocabScreen extends StatefulWidget {
  final String level;
  final String? topic;

  const AllVocabScreen({
    super.key,
    required this.level,
    this.topic,
  });

  @override
  State<AllVocabScreen> createState() => _AllVocabScreenState();
}

class _AllVocabScreenState extends State<AllVocabScreen> {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  final DictionaryService _dictionaryService = DictionaryService();
  final TextEditingController _searchController = TextEditingController();

  bool isLoading = true;
  Map<String, List<String>> topicWords = {};
  Map<String, Map<String, dynamic>> wordDetails = {};
  String _searchQuery = '';
  Map<String, dynamic>? _activeFilters;

  @override
  void initState() {
    super.initState();
    _fetchAllWords();
    if (widget.topic != null) {
      _activeFilters = {
        'cefrLevels': [widget.level],
        'topics': [widget.topic!],
        'partOfSpeech': [], // เพิ่มตัวกรองประเภทของคำว่าง
      };
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllWords() async {
    setState(() => isLoading = true);

    try {
      topicWords = await _dictionaryService.fetchWordsByLevel(widget.level);

      // โหลดข้อมูลเพิ่มเติมจากระดับอื่นๆ (ถ้ามี)
      if (_activeFilters != null && _activeFilters!.containsKey('cefrLevels')) {
        final selectedLevels = List<String>.from(_activeFilters!['cefrLevels']);
        for (final level in selectedLevels) {
          if (level != widget.level) {
            final additionalWords =
                await _dictionaryService.fetchWordsByLevel(level);
            additionalWords.forEach((topic, words) {
              if (topicWords.containsKey(topic)) {
                final existingWords = Set<String>.from(topicWords[topic]!);
                final newWords =
                    words.where((word) => !existingWords.contains(word));
                topicWords[topic]!.addAll(newWords);
              } else {
                topicWords[topic] = words;
              }
            });
          }
        }
      }

      // เพิ่มการโหลดรายละเอียดคำศัพท์ทั้งหมดล่วงหน้า
      // เพื่อให้สามารถกรองได้ถูกต้อง
      await _preloadWordDetails();

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      if (kDebugMode) {
        print('Error fetching words: $e');
      }
    }
  }

  // เพิ่มฟังก์ชันโหลดรายละเอียดคำศัพท์ล่วงหน้า
  Future<void> _preloadWordDetails() async {
    // โหลดเฉพาะคำศัพท์ที่เกี่ยวข้องกับการกรอง
    List<String> wordsToLoad = [];

    for (var entry in topicWords.entries) {
      final topic = entry.key;
      final words = entry.value;

      // ตรวจสอบว่าผ่านการกรองหัวข้อ (topic) หรือไม่
      bool includeThisTopic = true;
      if (_activeFilters != null && _activeFilters!.containsKey('topics')) {
        final selectedTopics = List<String>.from(_activeFilters!['topics']);
        if (selectedTopics.isNotEmpty && !selectedTopics.contains(topic)) {
          includeThisTopic = false;
        }
      }

      if (includeThisTopic) {
        // กรองคำศัพท์ตามการค้นหา
        final filteredWords = _searchQuery.isEmpty
            ? words
            : words
                .where((word) => word.toLowerCase().contains(_searchQuery))
                .toList();

        wordsToLoad.addAll(filteredWords);
      }
    }

    // โหลดรายละเอียดคำศัพท์แบบแบตช์ (ทีละหลายคำ)
    const int batchSize = 10;
    for (int i = 0; i < wordsToLoad.length; i += batchSize) {
      final batch = wordsToLoad.skip(i).take(batchSize);
      await Future.wait(batch.map((word) async {
        if (!wordDetails.containsKey(word)) {
          final details = await _dictionaryService.fetchWordDetail(word);
          if (details != null) {
            wordDetails[word] = details;
          }
        }
      }));
    }
  }

  Future<void> _showWordDetail(String word, String topic) async {
    final wordData = await _fetchWordDetail(word);

    if (!mounted) return;

    if (wordData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่พบข้อมูลสำหรับคำว่า "$word"')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => VocabDetailWithAddDialog(
        wordId: word,
        vocabData: wordData,
        level: widget.level,
        topic: topic,
        userId: userId!,
      ),
    );
  }

  Future<Map<String, dynamic>?> _fetchWordDetail(String wordId) async {
    if (wordDetails.containsKey(wordId)) {
      return wordDetails[wordId];
    }

    final data = await _dictionaryService.fetchWordDetail(wordId);
    if (data != null) {
      wordDetails[wordId] = data;
    }

    return data;
  }

  void _applyFilters(Map<String, dynamic> filters) {
    setState(() {
      _activeFilters = filters;
      _fetchAllWords();
    });
  }

  // ปรับปรุงวิธีการนับคำศัพท์ที่ผ่านการกรอง
  int _getTotalFilteredWords() {
    int total = 0;

    // ตรวจสอบว่ามีการเลือกประเภทคำหรือไม่
    bool hasPartOfSpeechFilter = _activeFilters != null &&
        _activeFilters!.containsKey('partOfSpeech') &&
        (_activeFilters!['partOfSpeech'] as List).isNotEmpty;

    for (var entry in topicWords.entries) {
      final topic = entry.key;
      final words = entry.value;

      // กรองตามหัวข้อ (topic)
      if (_activeFilters != null && _activeFilters!.containsKey('topics')) {
        final selectedTopics = List<String>.from(_activeFilters!['topics']);
        if (selectedTopics.isNotEmpty && !selectedTopics.contains(topic)) {
          continue;
        }
      }

      // กรองตามคำค้นหา
      final filteredWords = _searchQuery.isEmpty
          ? words
          : words
              .where((word) => word.toLowerCase().contains(_searchQuery))
              .toList();

      if (filteredWords.isEmpty) continue;

      // ถ้ามีการกรองตามประเภทของคำ
      if (hasPartOfSpeechFilter) {
        final selectedPartOfSpeech =
            List<String>.from(_activeFilters!['partOfSpeech']);
        final posFilteredWords =
            _filterWordsByPartOfSpeech(filteredWords, selectedPartOfSpeech);
        total += posFilteredWords.length;
      } else {
        // ไม่มีการกรองตามประเภทของคำ
        total += filteredWords.length;
      }
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    bootstrapGridParameters(gutterSize: 16);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('รายการคำศัพท์ทั้งหมด', style: AppTextStyles.headline),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          BootstrapContainer(
            fluid: true,
            children: [
              BootstrapRow(
                children: [
                  BootstrapCol(
                    sizes: 'col-xs-12 col-sm-12 col-md-8 col-lg-6',
                    offsets: 'offset-xs-0 offset-sm-0 offset-md-2 offset-lg-3',
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DictionarySearchBar(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() => _searchQuery = value.toLowerCase());
                        },
                        onFilterApplied: (filters) {
                          _applyFilters(filters); // ใช้ฟังก์ชันใหม่
                        },
                        activeFilters: _activeFilters,
                      ),
                    ),
                  ),
                ],
              ),
              // เพิ่ม Row ใหม่สำหรับแสดงจำนวนคำศัพท์
              if (!isLoading)
                BootstrapRow(
                  children: [
                    BootstrapCol(
                      sizes: 'col-xs-12 col-sm-12 col-md-8 col-lg-6',
                      offsets:
                          'offset-xs-0 offset-sm-0 offset-md-2 offset-lg-3',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        child: Text(
                          'พบคำศัพท์ทั้งหมด ${_getTotalFilteredWords()} คำ',
                          style: AppTextStyles.body.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: BootstrapContainer(
                      fluid: true,
                      children: [
                        BootstrapRow(
                          children: [
                            BootstrapCol(
                              sizes: 'col-xs-12 col-sm-12 col-md-8 col-lg-6',
                              offsets:
                                  'offset-xs-0 offset-sm-0 offset-md-2 offset-lg-3',
                              child: Column(
                                children: topicWords.entries.map((entry) {
                                  final topic = entry.key;
                                  final words = entry.value;

                                  if (_activeFilters != null) {
                                    final selectedTopics = List<String>.from(
                                        _activeFilters!['topics']);

                                    if (selectedTopics.isNotEmpty &&
                                        !selectedTopics.contains(topic)) {
                                      return const SizedBox.shrink();
                                    }
                                  }

                                  // กรองคำตามคำค้นหา
                                  final filteredWords = _searchQuery.isEmpty
                                      ? words
                                      : words
                                          .where((word) => word
                                              .toLowerCase()
                                              .contains(_searchQuery))
                                          .toList();

                                  if (filteredWords.isEmpty) {
                                    return const SizedBox.shrink();
                                  }

                                  // เพิ่มการกรองตามประเภทของคำ
                                  List<String> finalFilteredWords =
                                      filteredWords;
                                  if (_activeFilters != null &&
                                      _activeFilters!
                                          .containsKey('partOfSpeech') &&
                                      _activeFilters!['partOfSpeech']
                                          .isNotEmpty) {
                                    finalFilteredWords =
                                        _filterWordsByPartOfSpeech(
                                            filteredWords,
                                            List<String>.from(_activeFilters![
                                                'partOfSpeech']));
                                    if (finalFilteredWords.isEmpty) {
                                      return const SizedBox.shrink();
                                    }
                                  }

                                  final sortedWords = _dictionaryService
                                      .getSortedWords(finalFilteredWords);

                                  return TopicWordListSection(
                                    topic: topic,
                                    formattedTopic: _dictionaryService
                                        .formatTopicName(topic),
                                    sortedWords: sortedWords,
                                    onWordTap: (word) =>
                                        _showWordDetail(word, topic),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ปรับปรุงฟังก์ชันกรองประเภทของคำให้มีความยืดหยุ่นมากขึ้น
  List<String> _filterWordsByPartOfSpeech(
      List<String> words, List<String> partOfSpeech) {
    if (partOfSpeech.isEmpty) return words;

    List<String> filteredWords = [];

    for (var word in words) {
      if (wordDetails.containsKey(word)) {
        final details = wordDetails[word];
        if (details == null) continue;

        bool matchesPartOfSpeech = false;

        // ตรวจสอบจากฟิลด์ 'partOfSpeech' โดยตรง
        if (details.containsKey('partOfSpeech')) {
          final pos = details['partOfSpeech'] as String?;
          if (pos != null && partOfSpeech.contains(pos)) {
            matchesPartOfSpeech = true;
          }
        }

        // ตรวจสอบจาก 'mainPos'
        if (!matchesPartOfSpeech && details.containsKey('mainPos')) {
          final mainPos = details['mainPos'] as String?;
          if (mainPos != null && partOfSpeech.contains(mainPos)) {
            matchesPartOfSpeech = true;
          }
        }

        // ตรวจสอบจาก 'senses'
        if (!matchesPartOfSpeech && details.containsKey('senses')) {
          final senses = details['senses'];
          if (senses is List && senses.isNotEmpty) {
            for (var sense in senses) {
              if (sense is Map && sense.containsKey('partOfSpeech')) {
                final sensePos = sense['partOfSpeech'] as String?;
                if (sensePos != null && partOfSpeech.contains(sensePos)) {
                  matchesPartOfSpeech = true;
                  break;
                }
              }
            }
          }
        }

        if (matchesPartOfSpeech) {
          filteredWords.add(word);
        }
      }
    }

    return filteredWords;
  }
}
