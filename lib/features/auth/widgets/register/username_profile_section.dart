import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import 'package:vocabtree/core/utils/responsive_helper.dart';

class UsernameProfileSection extends StatelessWidget {
  final TextEditingController usernameController;
  final XFile? imageFile;
  final Function({XFile? imageFile, String? profileImageUrl}) onImageUpdate;

  const UsernameProfileSection({
    super.key,
    required this.usernameController,
    required this.imageFile,
    required this.onImageUpdate,
  });

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? selectedImage = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (selectedImage != null) {
        // ส่งเฉพาะ imageFile
        onImageUpdate(imageFile: selectedImage);
      }
    } catch (e) {
      debugPrint('เกิดข้อผิดพลาดในการเลือกรูป: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // สร้าง Row แทน และจัดให้อยู่ในแถวเดียวกัน
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ช่องกรอกชื่อผู้ใช้
        Expanded(
          child: _buildUsernameField(),
        ),
        // รูปโปรไฟล์
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: _buildProfilePicture(context),
        ),
      ],
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: usernameController,
      style: AppTextStyles.inputText,
      decoration: InputDecoration(
        labelText: 'ชื่อผู้ใช้งาน',
        border: const OutlineInputBorder(),
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

  Widget _buildProfilePicture(BuildContext context) {
    final double radius =
        ResponsiveHelper.getScreenWidth(context) > 600 ? 50 : 45;
    final double iconButtonRadius = radius * 0.36;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey[300],
          backgroundImage: imageFile != null
              ? (kIsWeb
                  ? NetworkImage(imageFile!.path)
                  : FileImage(File(imageFile!.path))) as ImageProvider?
              : null,
          child: imageFile == null
              ? Icon(
                  Icons.person,
                  size: radius * 1.2,
                  color: Colors.grey[600],
                )
              : null,
        ),
        // ปุ่มเพิ่มรูปโปรไฟล์
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: iconButtonRadius,
            backgroundColor: Colors.grey[600],
            child: IconButton(
              iconSize: iconButtonRadius * 1.2,
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              onPressed: () => _showImageSourceDialog(context),
            ),
          ),
        ),
      ],
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เลือกรูปโปรไฟล์'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('เลือกจากแกลเลอรี'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('ถ่ายรูป'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }
}
