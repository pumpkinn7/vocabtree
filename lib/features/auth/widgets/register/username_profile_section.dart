import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import 'package:vocabtree/core/utils/responsive_helper.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UsernameProfileSection extends StatefulWidget {
  final TextEditingController usernameController;
  final XFile? imageFile;
  final Function({XFile? imageFile, String? profileImageUrl}) onImageUpdate;

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
      await _uploadImage(pickedFile);
    }
  }

  Future<void> _uploadImage(XFile imageFile) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${DateTime.now().toIso8601String()}.jpg');

      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        await ref.putData(bytes);
      } else {
        await ref.putFile(File(imageFile.path));
      }

      final url = await ref.getDownloadURL();
      widget.onImageUpdate(imageFile: imageFile, profileImageUrl: url);
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading image: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เกิดข้อผิดพลาดในการอัปโหลดรูปภาพ')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = ResponsiveHelper.getScreenWidth(context);
    final isDesktop = screenWidth >= 992;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? screenWidth * 0.1 : 16.0,
      ),
      child: Column(
        children: [
          _buildProfilePicture(),
          const SizedBox(height: 20),
          _buildUsernameField(),
        ],
      ),
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: widget.usernameController,
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

  Widget _buildProfilePicture() {
    final double radius =
        ResponsiveHelper.getScreenWidth(context) > 600 ? 60 : 50;
    final double iconButtonRadius = radius * 0.36;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey[300],
          backgroundImage: widget.imageFile != null
              ? (kIsWeb
                  ? NetworkImage(widget.imageFile!.path)
                  : FileImage(File(widget.imageFile!.path)) as ImageProvider)
              : null,
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
