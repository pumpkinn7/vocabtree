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
      // ดึงข้อมูลจาก word_categories collection
      final categoriesQuery = await FirebaseFirestore.instance
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

      final wordDoc = await FirebaseFirestore.instance
          .collection('words')
          .doc(wordId)
          .get();

      if (!wordDoc.exists) return null;

      final data = wordDoc.data()!;
      wordDetails[wordId] = data;
      return data;
    } catch (e) {
      return null;
    }
  }

  String _formatTopicName(String topic) {
    return topic
        .split('_')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('คำศัพท์ระดับ ${widget.level}'),
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
                    itemBuilder: (context, index) {
                      final topic = topicWords.keys.elementAt(index);
                      final words = topicWords[topic] ?? [];
                      
                      // กรองคำศัพท์ตาม search query
                      final filteredWords = words.where((word) => 
                        word.toLowerCase().contains(_searchQuery)).toList();

                      if (filteredWords.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return ExpansionTile(
                        title: Text(_formatTopicName(topic)),
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: filteredWords.map((word) {
                              return Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: OutlinedButton(
                                  onPressed: () async {
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
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 8.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    side: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  child: Text(word),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
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
