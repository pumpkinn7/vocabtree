import 'package:flutter/material.dart';

class TopicModel {
  final String id;
  final String title;
  final int index;
  final bool isUnlocked;
  final String? imagePath;
  final String cefrLevel;

  TopicModel({
    required this.id,
    required this.title,
    required this.index,
    required this.isUnlocked,
    this.imagePath,
    required this.cefrLevel,
  });

  String get formattedTitle =>
      '${index + 1}. ${title.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ')}';

  Color get statusColor => isUnlocked ? Colors.green : Colors.grey;
}
