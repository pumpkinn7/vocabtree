import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TopWrongWords extends StatelessWidget {
  final List<Map<String, dynamic>> wrongWords;
  final VoidCallback onViewAllPressed;

  const TopWrongWords({
    super.key,
    required this.wrongWords,
    required this.onViewAllPressed,
  });

  String _formatTopicName(String topic) {
    return topic
        .split('_')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    if (wrongWords.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.check_circle, color: Colors.green[300], size: 48),
                const SizedBox(height: 8),
                const Text(
                  'ยังไม่มีคำศัพท์ที่ตอบผิด',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'คำศัพท์ที่ตอบผิดบ่อย',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: onViewAllPressed,
              child: const Text('ดูทั้งหมด'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: wrongWords.length,
          itemBuilder: (context, index) {
            final word = wrongWords[index];
            return Card(
              child: ListTile(
                title: Text(word['word']),
                subtitle: Text(
                  'ตอบผิด ${word['wrongCount']} ครั้ง\n'
                  'หมวด: ${_formatTopicName(word['topic'])}\n'
                  'ล่าสุด: ${DateFormat('dd/MM/yyyy').format(word['lastWrongAt'])}',
                ),
                trailing: CircleAvatar(
                  backgroundColor: Colors.red,
                  child: Text(
                    '${word['wrongCount']}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
