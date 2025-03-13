import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/vocab_detail_with_add_dialog.dart';

class AllVocabScreen extends StatefulWidget {
  final String level;

  const AllVocabScreen({super.key, required this.level});

  @override
  State<AllVocabScreen> createState() => _AllVocabScreenState();
}

class _AllVocabScreenState extends State<AllVocabScreen> {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  final _firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  Map<String, List<String>> topicWords = {};
  Map<String, Map<String, dynamic>> wordDetails = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchAllWords();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllWords() async {
    setState(() => isLoading = true);

    try {
      final categoriesQuery = await _firestore
          .collection('word_categories')
          .where('cefrLevel', isEqualTo: widget.level)
          .get();

      for (var doc in categoriesQuery.docs) {
        final words = List<String>.from(doc.data()['words'] ?? []);
        topicWords[doc.id] = words;
      }

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<Map<String, dynamic>?> _fetchWordDetail(String wordId) async {
    try {
      if (wordDetails.containsKey(wordId)) {
        return wordDetails[wordId];
      }

      final wordDoc = await _firestore.collection('words').doc(wordId).get();

      if (!wordDoc.exists) return null;

      final data = wordDoc.data()!;
      wordDetails[wordId] = data;
      return data;
    } catch (e) {
      return null;
    }
  }

  // เพิ่มเมธอดสำหรับจัดเรียงคำศัพท์
  Map<String, List<String>> _getSortedWords(List<String> words) {
    final Map<String, List<String>> sortedMap = {};
    final sortedWords = List<String>.from(words)..sort();
    for (var word in sortedWords) {
      final firstLetter = word[0].toUpperCase();
      if (!sortedMap.containsKey(firstLetter)) {
        sortedMap[firstLetter] = [];
      }
      sortedMap[firstLetter]!.add(word);
    }
    return sortedMap;
  }

  String _formatTopicName(String topic) {
    return topic
        .split('_')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('พจนานุกรมคำศัพท์'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ค้นหาคำศัพท์...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: topicWords.length,
                    itemBuilder: (context, topicIndex) {
                      final topic = topicWords.keys.elementAt(topicIndex);
                      final words = topicWords[topic] ?? [];

                      // กรองคำตาม search query
                      final filteredWords = _searchQuery.isEmpty
                          ? words
                          : words
                              .where((word) =>
                                  word.toLowerCase().contains(_searchQuery))
                              .toList();

                      if (filteredWords.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      final sortedWords = _getSortedWords(filteredWords);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              _formatTopicName(topic),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          ...sortedWords.entries.map((entry) {
                            final letter = entry.key;
                            final letterWords = entry.value;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: theme.primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          letter,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                color:
                                                    theme.colorScheme.onPrimary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child:
                                            Divider(color: theme.primaryColor),
                                      ),
                                    ],
                                  ),
                                ),
                                ...letterWords.map((word) => ListTile(
                                      title: Text(word),
                                      onTap: () async {
                                        final wordData =
                                            await _fetchWordDetail(word);
                                        if (!mounted) return;

                                        if (wordData == null) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'ไม่พบข้อมูลสำหรับคำว่า "$word"'),
                                            ),
                                          );
                                          return;
                                        }

                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              VocabDetailWithAddDialog(
                                            wordId: word,
                                            vocabData: wordData,
                                            level: widget.level,
                                            topic: topic,
                                            userId: userId!,
                                          ),
                                        );
                                      },
                                    )),
                              ],
                            );
                          }),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
