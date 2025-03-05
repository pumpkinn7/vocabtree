import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import 'package:vocabtree/features/profile/models/profile_model.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileModel profile;
  final Function(File) onImageSelected;

  const ProfileHeader({
    super.key,
    required this.profile,
    required this.onImageSelected,
  });

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      onImageSelected(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BootstrapContainer(
      fluid: true,
      children: [
        BootstrapRow(
          children: [
            BootstrapCol(
              sizes: 'col-12',
              child: Center(
                child: Column(
                  children: [
                    _buildProfilePicture(),
                    const SizedBox(height: 10),
                    Text(
                      profile.username ?? 'ไม่พบข้อมูลผู้ใช้',
                      style: AppTextStyles.headline,
                    ),
                    Text(
                      'เข้าร่วมเมื่อ: ${profile.getFormattedDate()}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfilePicture() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[300],
            backgroundImage: profile.profileImageUrl != null
                ? NetworkImage(profile.profileImageUrl!)
                : null,
            child: profile.profileImageUrl == null
                ? const Icon(Icons.person, color: Colors.white, size: 40)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              backgroundColor: Colors.grey[700],
              radius: 20,
              child: IconButton(
                icon:
                    const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                onPressed: _pickImage,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
