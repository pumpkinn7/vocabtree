import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final int current;
  final int total;

  const ProgressBar({
    super.key,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    double progress = (current / total).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question $current of $total',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      ],
    );
  }
}
