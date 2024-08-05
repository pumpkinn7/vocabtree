// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vocabtree/theme/text_styles.dart';
import 'package:vocabtree/theme/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user!.uid)
          .get();
      setState(() {
        userData = snapshot.data();
      });
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context)
        .pushReplacementNamed('/login'); // Redirect to login page
  }

  Future<void> _changeProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null && user != null) {
      File imageFile = File(image.path);
      String fileName = '${user!.uid}.jpg';

      try {
        // Upload image to Firebase Storage
        UploadTask uploadTask = FirebaseStorage.instance
            .ref('profile_images/$fileName')
            .putFile(imageFile);

        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Update Firestore with the new image URL
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({'profileImageUrl': downloadUrl});

        setState(() {
          userData?['profileImageUrl'] = downloadUrl;
        });
      } catch (e) {
        if (kDebugMode) {
          print('Error uploading profile picture: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    Timestamp? joinDateTimestamp = userData?['createdAt'] as Timestamp?;
    String joinDate = joinDateTimestamp != null
        ? '${joinDateTimestamp.toDate().day}/${joinDateTimestamp.toDate().month}/${joinDateTimestamp.toDate().year}'
        : 'ไม่ทราบ';

    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'รายงานปัญหา',
                    style: AppTextStyles.label.copyWith(color: Colors.orange),
                  ),
                ),
              ),
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _changeProfilePicture,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: userData != null &&
                                    userData!['profileImageUrl'] != null
                                ? NetworkImage(userData!['profileImageUrl'])
                                : null,
                            child: userData != null &&
                                    userData!['profileImageUrl'] != null
                                ? null
                                : const Icon(
                                    Icons.account_circle,
                                    size: 130,
                                    color: Colors.grey,
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: Colors.grey[700],
                              radius: 20,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                onPressed: _changeProfilePicture,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        userData?['username'] ??
                            'ดูเหมือนจะเกิดข้อผิดพลาดในการดึงข้อมูล!',
                        style: AppTextStyles.headline,
                      ),
                    ),
                    Text(
                      'เข้าร่วมเมื่อ: $joinDate',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildTextFieldContainer(
                  'ชื่อผู้ใช้งาน',
                  userData?['username'] ??
                      'ดูเหมือนจะเกิดข้อผิดพลาดในการดึงข้อมูล!'),
              const SizedBox(height: 5),
              _buildTextFieldContainer('อีเมลของฉัน',
                  user?.email ?? 'ดูเหมือนจะเกิดข้อผิดพลาดในการดึงข้อมูล!'),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'การแสดงผลหน้าจอ',
                    style: AppTextStyles.label,
                  ),
                  const SizedBox(width: 5),
                  SizedBox(
                    width: 65,
                    child: DayNightSwitcher(
                      isDarkModeEnabled:
                          themeProvider.themeMode == ThemeMode.dark,
                      onStateChanged: (isDarkModeEnabled) {
                        themeProvider.toggleTheme(isDarkModeEnabled);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 80,
                      child: Image.asset(
                        'assets/images/friend_edit.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 80,
                      child: Image.asset(
                        'assets/images/profile_edit.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Center(
                child: TextButton(
                  onPressed: _signOut,
                  child: Text(
                    'ออกจากระบบ',
                    style: AppTextStyles.label.copyWith(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldContainer(String label, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 23, top: 5),
          child: Text(
            label,
            style: AppTextStyles.label,
          ),
        ),
        Container(
          width: double.infinity,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: AppTextStyles.inputText,
            ),
          ),
        ),
      ],
    );
  }
}
