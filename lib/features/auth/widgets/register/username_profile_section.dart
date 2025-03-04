import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import 'package:vocabtree/core/utils/responsive_helper.dart';

class UsernameProfileSection extends StatefulWidget {
  final TextEditingController usernameController;
  final File? imageFile;
  final Function({File? imageFile, String? profileImageUrl}) onImageUpdate;

  const UsernameProfileSection({
    super.key,
    required this.usernameController,
    required this.imageFile,
    required this.onImageUpdate,
  });

  @override
  State<UsernameProfileSection> createState() => _UsernameProfileSectionState();
}

class _UsernameProfileSectionState extends State<UsernameProfileSection> {
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      await _uploadImage(imageFile);
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${DateTime.now().toIso8601String()}.jpg');
      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();

      widget.onImageUpdate(imageFile: imageFile, profileImageUrl: url);
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading image: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เกิดข้อผิดพลาดในการอัปโหลดรูปภาพ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ดึงขนาดของหน้าจอมาเพื่อปรับรูปแบบการแสดงผล
    final screenWidth = ResponsiveHelper.getScreenWidth(context);

    // ถ้าหน้าจอแคบ (โทรศัพท์ในแนวตั้ง) ให้แสดง Column แทน Row
    if (screenWidth < 500) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildProfilePicture(),
          const SizedBox(height: 16),
          _buildUsernameField(),
        ],
      );
    }

    // ถ้าหน้าจอกว้าง ให้แสดง Row ตามเดิม
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _buildUsernameField()),
        const SizedBox(width: 20),
        _buildProfilePicture(),
      ],
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: widget.usernameController,
      decoration: InputDecoration(
        labelText: 'ชื่อผู้ใช้งาน',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        labelStyle: AppTextStyles.inputText,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'กรุณากรอกชื่อผู้ใช้งาน';
        }
        return null;
      },
    );
  }

  Widget _buildProfilePicture() {
    // ปรับขนาดของรูปโปรไฟล์ให้เหมาะสมกับขนาดหน้าจอ
    final double radius =
        ResponsiveHelper.getScreenWidth(context) > 600 ? 60 : 50;
    final double iconButtonRadius = radius * 0.36;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey[300],
          backgroundImage:
              widget.imageFile != null ? FileImage(widget.imageFile!) : null,
          child: widget.imageFile == null
              ? Icon(Icons.person, size: radius, color: Colors.white)
              : null,
        ),
        CircleAvatar(
          backgroundColor: Colors.grey[700],
          radius: iconButtonRadius,
          child: IconButton(
            icon: Icon(Icons.camera_alt,
                size: iconButtonRadius * 0.8, color: Colors.white),
            onPressed: _pickImage,
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
