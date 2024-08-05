import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:vocabtree/services/auth_service.dart';
import 'package:vocabtree/theme/text_styles.dart';
import 'package:vocabtree/theme/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final Logger _logger = Logger();
  Map<String, dynamic>? userData;
  Map<String, dynamic>? profileData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        DocumentSnapshot<Map<String, dynamic>> profileSnapshot =
            await FirebaseFirestore.instance
                .collection('profiles')
                .doc(user.uid)
                .get();

        setState(() {
          userData = userSnapshot.data();
          profileData = profileSnapshot.data();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'User is not logged in.';
        });
      }
    } catch (e) {
      _logger.e('Error loading user data: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load user data. Please try again.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage!)),
      );
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      _logger.e('Error signing out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('เกิดข้อผิดพลาดในการออกจากระบบ กรุณาลองใหม่อีกครั้ง')),
      );
    }
  }

  Future<void> _uploadProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && FirebaseAuth.instance.currentUser != null) {
      final file = File(pickedFile.path);
      final fileName = '${FirebaseAuth.instance.currentUser!.uid}.jpg';

      try {
        // Upload image to Firebase Storage
        final uploadTask = FirebaseStorage.instance
            .ref('profile_images/$fileName')
            .putFile(file);
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();

        // Update Firestore with the new image URL
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
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

  Future<void> _toggleDisplayMode(bool isDarkModeEnabled) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('profiles')
            .doc(user.uid)
            .update({
          'settings.displayMode': isDarkModeEnabled ? 'dark' : 'light',
        });
      }
    } catch (e) {
      _logger.e('Error updating user theme preference: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'เกิดข้อผิดพลาดในการบันทึกการตั้งค่า กรุณาลองใหม่อีกครั้ง')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Text(errorMessage!),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              _buildTopRightButton('รายงานปัญหา', Colors.orange),
              const SizedBox(height: 20),
              _buildProfileSection(),
              const SizedBox(height: 30),
              _buildTextFieldContainer('ชื่อผู้ใช้งาน',
                  profileData?['username'] ?? 'เกิดข้อผิดพลาดในการดึงข้อมูล!'),
              const SizedBox(height: 5),
              _buildTextFieldContainer(
                  'อีเมลของฉัน',
                  FirebaseAuth.instance.currentUser?.email ??
                      'เกิดข้อผิดพลาดในการดึงข้อมูล!'),
              const SizedBox(height: 30),
              _buildDisplayModeSwitch(themeProvider),
              const SizedBox(height: 20),
              _buildActionButtons(),
              const SizedBox(height: 15),
              _buildSignOutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopRightButton(String label, Color color) {
    return Align(
      alignment: Alignment.topRight,
      child: TextButton(
        onPressed: () {},
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(color: color),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Center(
      child: Column(
        children: [
          _buildProfilePicture(),
          const SizedBox(height: 5),
          Text(
            profileData?['username'] ?? 'เกิดข้อผิดพลาดในการดึงข้อมูล!',
            style: AppTextStyles.headline,
          ),
          Text(
            'เข้าร่วมเมื่อ: ${_formatDate(profileData?['createdAt'])}',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePicture() {
    return GestureDetector(
      onTap: _uploadProfilePicture,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[300],
            backgroundImage: userData?['profileImageUrl'] != null
                ? NetworkImage(userData!['profileImageUrl'])
                : null,
          ),
          if (userData?['profileImageUrl'] == null)
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white, size: 40),
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
                onPressed: _uploadProfilePicture,
              ),
            ),
          ),
        ],
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

  Widget _buildDisplayModeSwitch(ThemeProvider themeProvider) {
    return Row(
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
            isDarkModeEnabled: themeProvider.themeMode == ThemeMode.dark,
            onStateChanged: (isDarkModeEnabled) {
              themeProvider.toggleTheme(isDarkModeEnabled);
              _toggleDisplayMode(isDarkModeEnabled);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: _buildButton('แก้ไขเพื่อน'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildButton('จัดการบัญชี'),
        ),
      ],
    );
  }

  Widget _buildButton(String label) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.grey),
        ),
      ),
      onPressed: () {},
      child: Text(label),
    );
  }

  Widget _buildSignOutButton() {
    return Center(
      child: TextButton(
        onPressed: _signOut,
        child: Text(
          'ออกจากระบบ',
          style: AppTextStyles.label.copyWith(color: Colors.red),
        ),
      ),
    );
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'ไม่ทราบ';
    DateTime date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
}
