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

  @override
  Widget build(BuildContext context) {
    if (wrongWords.isEmpty) {
      return const SizedBox.shrink();
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
