import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FlashcardSummaryScreen extends StatefulWidget {
  final String userId;
  final String topic;
  final String level;
  final int knownCount;
  final int unknownCount;
  final int reviewCount;
  final int totalCount;

  const FlashcardSummaryScreen({
    super.key,
    required this.userId,
    required this.topic,
    required this.level,
    required this.knownCount,
    required this.unknownCount,
    required this.reviewCount,
    required this.totalCount,
  });

  @override
  State<FlashcardSummaryScreen> createState() => _FlashcardSummaryScreenState();
}

class _FlashcardSummaryScreenState extends State<FlashcardSummaryScreen> {
  bool _isResetting = false;

  /// เพิ่ม: สำหรับแสดงคำศัพท์ที่ไม่รู้ (is_known = false)
  List<Map<String, dynamic>> _unknownWords = [];

  /// เพิ่ม: สำหรับเก็บคำศัพท์ (word) ที่ผู้ใช้เลือกไว้
  final Set<String> _selectedWords = {};

  /// เพิ่ม: สำหรับสถานะกำลังเพิ่มเข้าคลัง
  bool _isAddingToBank = false;

  @override
  void initState() {
    super.initState();
    _fetchUnknownWords();
  }

  /// ฟังก์ชันใหม่: ดึงคำศัพท์ที่ is_known = false, for_review = false จาก Firestore
  Future<void> _fetchUnknownWords() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection(widget.level)
          .doc(widget.topic)
          .collection('vocabularies')
          .where('is_known', isEqualTo: false)
          .where('for_review', isEqualTo: false)
          .get();

      final tempList = querySnapshot.docs.map((doc) {
        return {
          'word': doc.id,
          ...doc.data(),
        };
      }).toList();

      setState(() {
        _unknownWords = tempList;
      });
    } catch (e) {
      debugPrint('Error fetching unknown words: $e');
    }
  }

  /// ฟังก์ชันใหม่: เมื่อผู้ใช้กด "เพิ่มเข้าคลังคำศัพท์"
  Future<void> _addSelectedWordsToBank() async {
    if (_selectedWords.isEmpty) return; // ถ้าไม่มีคำที่ถูกเลือก ก็ไม่ต้องทำอะไร

    setState(() {
      _isAddingToBank = true;
    });

    try {
      final vocabRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection(widget.level)
          .doc(widget.topic)
          .collection('vocabularies');

      // อัปเดต for_review = true เฉพาะคำที่อยู่ใน _selectedWords
      for (String word in _selectedWords) {
        await vocabRef.doc(word).update({
          'for_review': true,
        });
      }

      // อัปเดต UI: ลบคำที่ถูกเลือกออกจาก _unknownWords
      _unknownWords.removeWhere((vocab) => _selectedWords.contains(vocab['word']));

      // เคลียร์การเลือก
      _selectedWords.clear();

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

  /// (คงอยู่) ฟังก์ชันเดิม: Reset คำศัพท์ทั้งหมด
  Future<void> _resetAllWords() async {
    setState(() {
      _isResetting = true;
    });

    try {
      // รีเซ็ตค่าทุกคำใน topic นี้ (is_known = false, for_review = false)
      final query = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection(widget.level)
          .doc(widget.topic)
          .collection('vocabularies')
          .get();

      for (var doc in query.docs) {
        await doc.reference.update({
          'is_known': false,
          'for_review': false,
        });
      }

      // หลัง Reset เสร็จ จะ pop กลับ
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
    // Disabled หรือ Enabled ของปุ่ม "เพิ่มเข้าคลังคำศัพท์"
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
            // ----- ส่วนสรุปสถิติ (เหมือนเดิม) -----
            Text("จำนวนคำศัพท์ทั้งหมด: ${widget.totalCount}"),
            const SizedBox(height: 8),
            Text("คำศัพท์ที่รู้ (Known): ${widget.knownCount}"),
            const SizedBox(height: 8),
            Text("คำศัพท์ที่ไม่รู้ (Unknown): ${widget.unknownCount}"),
            const SizedBox(height: 8),
            Text("คำศัพท์ที่ต้องทบทวน (Review): ${widget.reviewCount}"),
            const SizedBox(height: 24),

            // ----- ส่วนใหม่: แสดงคำศัพท์ที่ไม่รู้ (is_known = false) -----
            const Divider(),
            const Text(
              "รายการคำศัพท์ที่ยังไม่รู้",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // ถ้าไม่มีคำศัพท์ไม่รู้ ก็แจ้งว่าไม่มี
            if (_unknownWords.isEmpty)
              const Text("ไม่มีคำศัพท์ที่ไม่รู้แล้ว!")
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _unknownWords.map((vocab) {
                  final word = vocab['word'] ?? '';
                  final bool isSelected = _selectedWords.contains(word);

                  return OutlinedButton(
                    onPressed: () {
                      setState(() {
                        // ถ้าคำนี้ถูกเลือกแล้ว -> เอาออก
                        // ถ้ายังไม่ถูกเลือก -> ใส่เข้าไป
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
                          color:
                          isSelected ? Colors.blue : Colors.grey),
                    ),
                    child: Text(word),
                  );
                }).toList(),
              ),

            const SizedBox(height: 24),

            // ----- แถวปุ่ม "เพิ่มเข้าคลังคำศัพท์" (ซ้าย) + Reset (ขวา) -----
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ปุ่ม "เพิ่มเข้าคลังคำศัพท์"
                ElevatedButton(
                  onPressed: canAddToBank ? _addSelectedWordsToBank : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    disabledBackgroundColor:
                    Colors.grey.shade300, // ปุ่มจาง
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

                // ปุ่ม "Reset" (เดิม)
                ElevatedButton(
                  onPressed: _resetAllWords,
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
