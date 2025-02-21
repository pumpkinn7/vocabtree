import 'package:flutter/material.dart';

class ScoreProgress extends StatelessWidget {
  final double percentage;

  const ScoreProgress({super.key, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            FractionallySizedBox(
              widthFactor: percentage / 100,
              child: Container(
                height: 24,
                decoration: BoxDecoration(
                  color: percentage >= 60 ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.6 - 32,
              top: 0,
              bottom: 0,
              child: Container(width: 2, color: Colors.black54),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  color: percentage >= 60 ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text('ตอบถูก: ${percentage.toStringAsFixed(1)}%'),
              ],
            ),
            Row(
              children: [
                Container(width: 2, height: 16, color: Colors.black54),
                const SizedBox(width: 8),
                const Text('เกณฑ์ผ่าน: 60%'),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
