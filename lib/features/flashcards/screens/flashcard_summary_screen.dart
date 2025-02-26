import 'package:flutter/material.dart';

import '../model/swipe_direction.dart'; // Add SwipeDirection import
import '../services/flashcard_service.dart';

class FlashcardSummaryScreen extends StatefulWidget {
  final String userId;
  final String topic;
  final int knownCount;
  final int unknownCount;
  final int reviewCount;
  final int totalCount;

  const FlashcardSummaryScreen({
    super.key,
    required this.userId,
    required this.topic,
    required this.knownCount,
    required this.unknownCount,
    required this.reviewCount,
    required this.totalCount,
  });

  @override
  State<FlashcardSummaryScreen> createState() => _FlashcardSummaryScreenState();
}

class _FlashcardSummaryScreenState extends State<FlashcardSummaryScreen> {
  final FlashcardService _service = FlashcardService();
  bool _isResetting = false;
  List<String> _unknownWords = [];
  final Set<String> _selectedWords = {};
  bool _isAddingToBank = false;

  @override
  void initState() {
    super.initState();
    _fetchUnknownWords();
  }

  Future<void> _fetchUnknownWords() async {
    try {
      final statuses = await _service.getWordStatuses(
        widget.userId,
        widget.topic,
      );

      setState(() {
        _unknownWords = statuses['unknown_words'] ?? [];
      });
    } catch (e) {
      debugPrint('Error fetching unknown words: $e');
    }
  }

  Future<void> _addSelectedWordsToBank() async {
    if (_selectedWords.isEmpty) return;

    setState(() {
      _isAddingToBank = true;
    });

    try {
      for (final word in _selectedWords) {
        await _service.saveWordStatus(
            widget.userId, widget.topic, word, SwipeDirection.up);
      }

      setState(() {
        _unknownWords.removeWhere((word) => _selectedWords.contains(word));
        _selectedWords.clear();
      });
    } catch (e) {
      debugPrint('Error adding words to bank: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToBank = false;
        });
      }
    }
  }

  Future<void> _confirmReset() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการรีเซ็ต'),
          content: const Text(
            'คุณแน่ใจหรือไม่ว่าต้องการรีเซ็ตคำศัพท์ทั้งหมด?\n'
            'สถานะของคำศัพท์ทั้งหมดจะถูกล้างและเริ่มต้นใหม่อีกครั้ง.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('ยืนยัน'),
            ),
          ],
        );
      },
    );

    if (shouldReset == true) {
      _resetAllWords();
    }
  }

  Future<void> _resetAllWords() async {
    setState(() {
      _isResetting = true;
    });

    try {
      await _service.resetTopic(widget.userId, widget.topic);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      debugPrint("Error resetting words: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isResetting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canAddToBank = _selectedWords.isNotEmpty && !_isAddingToBank;

    return Scaffold(
      appBar: AppBar(
        title: const Text('สรุปผล'),
      ),
      body: _isResetting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text("จำนวนคำศัพท์ทั้งหมด: ${widget.totalCount}"),
                  const SizedBox(height: 8),
                  Text("คำศัพท์ที่รู้ (Known): ${widget.knownCount}"),
                  const SizedBox(height: 8),
                  Text("คำศัพท์ที่ไม่รู้ (Unknown): ${widget.unknownCount}"),
                  const SizedBox(height: 8),
                  Text("คำศัพท์ที่ต้องทบทวน (Review): ${widget.reviewCount}"),
                  const SizedBox(height: 24),
                  const Divider(),
                  const Text(
                    "รายการคำศัพท์ที่ยังไม่รู้",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_unknownWords.isEmpty)
                    const Text("ไม่มีคำศัพท์ที่ไม่รู้แล้ว!")
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _unknownWords.map((word) {
                        final bool isSelected = _selectedWords.contains(word);

                        return OutlinedButton(
                          onPressed: () {
                            setState(() {
                              if (isSelected) {
                                _selectedWords.remove(word);
                              } else {
                                _selectedWords.add(word);
                              }
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                isSelected ? Colors.white : Colors.blue,
                            backgroundColor:
                                isSelected ? Colors.blueAccent : Colors.white,
                            side: BorderSide(
                                color: isSelected ? Colors.blue : Colors.grey),
                          ),
                          child: Text(word),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed:
                            canAddToBank ? _addSelectedWordsToBank : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: _isAddingToBank
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("เพิ่มเข้าคลังคำศัพท์"),
                      ),
                      ElevatedButton(
                        onPressed: _confirmReset,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text("Reset"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
