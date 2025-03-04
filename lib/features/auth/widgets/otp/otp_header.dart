import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class OtpHeader extends StatelessWidget {
  final String username;
  final File? profileImageFile;

  const OtpHeader({
    super.key,
    required this.username,
    this.profileImageFile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10), // ลดระยะห่างลงอีก
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[300],
          backgroundImage:
              profileImageFile != null ? FileImage(profileImageFile!) : null,
          child: profileImageFile == null
              ? const Icon(Icons.person, size: 50, color: Colors.grey)
              : null,
        ),
        const SizedBox(height: 16), // ลดระยะห่าง
        Text(
          'สวัสดีคุณ, $username',
          style: AppTextStyles.headline,
        ),
      ],
    );
  }
}
