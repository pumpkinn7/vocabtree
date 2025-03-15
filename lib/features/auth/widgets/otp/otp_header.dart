import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

class OtpHeader extends StatelessWidget {
  final String username;
  final XFile? profileImageFile;

  const OtpHeader({
    super.key,
    required this.username,
    this.profileImageFile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[300],
          backgroundImage: profileImageFile != null
              ? (kIsWeb
                  ? NetworkImage(profileImageFile!.path)
                  : FileImage(File(profileImageFile!.path)) as ImageProvider)
              : null,
          child: profileImageFile == null
              ? const Icon(Icons.person, size: 50, color: Colors.grey)
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          'สวัสดีคุณ, $username',
          style: AppTextStyles.headline,
        ),
      ],
    );
  }
}
