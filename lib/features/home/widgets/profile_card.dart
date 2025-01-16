import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final DateTime? joinedAt;
  final String imageUrl;

  const ProfileCard({
    super.key,
    required this.name,
    required this.joinedAt,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // รูปโปรไฟล์
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              backgroundImage:
              imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
              child: imageUrl.isEmpty
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              joinedAt != null
                  ? 'เข้าร่วมเมื่อ: ${joinedAt!.day}/${joinedAt!.month}/${joinedAt!.year}'
                  : 'ไม่ทราบวันที่เข้าร่วม',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}