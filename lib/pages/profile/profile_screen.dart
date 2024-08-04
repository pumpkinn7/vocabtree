// ignore_for_file: library_private_types_in_public_api

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 35),
              const Align(
                alignment: Alignment.topRight,
                child: Text(
                  'รายงานปัญหา',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
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
                            radius: 65, // เปลี่ยนขนาดรูปโปรไฟล์
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
                          CircleAvatar(
                            radius: 67,
                            backgroundColor: Colors.transparent,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFFE960D),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        userData?['username'] ??
                            'ดูเหมือนจะเกิดข้อผิดพลาดในการดึงข้อมูล!',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      'เข้าร่วมเมื่อ: ${userData?['joinDate'] ?? 'ดูเหมือนจะเกิดข้อผิดพลาดในการดึงข้อมูล!'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              _buildTextFieldContainer(
                  'ชื่อ',
                  userData?['username'] ??
                      'ดูเหมือนจะเกิดข้อผิดพลาดในการดึงข้อมูล!'),
              const SizedBox(height: 8),
              _buildTextFieldContainer('อีเมล',
                  user?.email ?? 'ดูเหมือนจะเกิดข้อผิดพลาดในการดึงข้อมูล!'),
              const SizedBox(height: 8),
              _buildTextFieldContainer('รหัสผ่าน', '**********'),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('การแสดงผลหน้าจอ'),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 65,
                    child: DayNightSwitcher(
                      isDarkModeEnabled: false,
                      onStateChanged: (isDarkModeEnabled) {
                        // Handle switch state
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
                  child: const Text(
                    'ออกจากระบบ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
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
          padding:
              const EdgeInsets.only(left: 20, top: 5), // เพิ่ม padding 5 pixel
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6D7278), // สี 6D7278
            ),
          ),
        ),
        Container(
          width: double.infinity, // ทำให้เต็มความกว้างของหน้าจอ
          height: 50, // กำหนดความสูงให้เท่ากัน และใหญ่ขึ้น 20 pixel
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xBF6D7278), // สี #6D7278 และมี opacity 75%
              ),
            ),
          ),
        ),
      ],
    );
  }
}
