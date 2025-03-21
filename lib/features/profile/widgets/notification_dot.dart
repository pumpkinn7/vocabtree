import 'package:flutter/material.dart';

class NotificationDot extends StatelessWidget {
  final bool showDot;
  final Color? color;
  final double size;

  const NotificationDot({
    super.key,
    required this.showDot,
    this.color,
    this.size = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    if (!showDot) return const SizedBox.shrink();

    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        color: color ?? Colors.red,
        shape: BoxShape.circle,
      ),
    );
  }
}
