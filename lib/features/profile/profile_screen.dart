import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vocabtree/core/theme/text_styles.dart';
import 'package:vocabtree/core/theme/theme_provider.dart';
import 'package:vocabtree/features/auth/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? userData;
  Map<String, dynamic>? profileData;
  bool isLoading = true;
  String? errorMessage;

  String _maskEmail(String email) {
    if (email.isEmpty) return '';

    final parts = email.split('@');
    if (parts.length != 2) return email;

    String username = parts[0];
    String domain = parts[1];

    if (username.length > 4) {
      username =
      '${username.substring(0, 2)}****${username.substring(username.length - 2)}';
    } else {
      username = username.replaceRange(1, null, '***');
    }

    return '$username@$domain';
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _showReportProblemDialog() {
    String? selectedProblem;
    final TextEditingController customProblemController = TextEditingController();
    final TextEditingController detailsController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('รายงานปัญหา', style: AppTextStyles.headline),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ปัญหาที่พบบ่อย:', style: AppTextStyles.label),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: selectedProblem,
                      hint: const Text('เลือกปัญหาที่พบ'),
                      items: [
                        'ข้อผิดพลาดในการทำแบบฝึกหัด',
                        'การซิงค์ข้อมูลระหว่างอุปกรณ์',
                        'ปัญหาเกี่ยวกับการเชื่อมต่ออินเทอร์เน็ต',
                        'การแจ้งเตือนที่ไม่สม่ำเสมอ',
                        'การอัปเดต และการดาวน์โหลดข้อมูล',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedProblem = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: customProblemController,
                      decoration: const InputDecoration(
                        labelText: 'ปัญหาที่ฉันพบ',
                        hintText: 'กรอกปัญหาที่คุณพบ',
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: detailsController,
                      decoration: const InputDecoration(
                        labelText: 'รายละเอียด',
                        hintText: 'กรอกรายละเอียดเพิ่มเติม',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('ยกเลิก'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('ส่งรายงาน'),
                  onPressed: () {
                    _submitReport(
                      selectedProblem,
                      customProblemController.text,
                      detailsController.text,
                    );
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showManageAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('จัดการบัญชี', style: AppTextStyles.headline),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/tree_6977598.png',
                width: 35,
                height: 35,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _handleResetPasswordAndSignOut();
                },
                child: const Text('ฉันลืมรหัสผ่าน', style: AppTextStyles.label),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _deleteAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child:
                const Text('ลบบัญชีผู้ใช้งาน', style: AppTextStyles.label),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ปิด', style: AppTextStyles.label),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleResetPasswordAndSignOut() async {
    final result = await Navigator.pushNamed(context, '/reset-password');
    if (result == true) {
      try {
        await FirebaseAuth.instance.signOut();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
              Text('คำขอรีเซ็ตรหัสผ่านถูกส่งแล้ว กรุณาตรวจสอบอีเมลของคุณ')),
        );

        Navigator.of(context).pushReplacementNamed('/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
              Text('เกิดข้อผิดพลาดในการออกจากระบบ กรุณาลองใหม่อีกครั้ง')),
        );
      }
    }
  }

  Future<void> _submitReport(
      String? commonIssue, String customIssue, String details) async {
    try {
      await FirebaseFirestore.instance.collection('reports').add({
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'commonIssue': commonIssue,
        'customIssue': customIssue,
        'issueDetails': details,
        'reportedAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('รายงานถูกส่งเรียบร้อยแล้ว')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('เกิดข้อผิดพลาดในการส่งรายงาน กรุณาลองใหม่อีกครั้ง')),
      );
    }
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
          errorMessage = 'ผู้ใช้งานยังไม่ได้เข้าสู่ระบบ.';
        });
      }
    } catch (e) {
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
        final uploadTask = FirebaseStorage.instance
            .ref('profile_images/$fileName')
            .putFile(file);
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({'profileImageUrl': downloadUrl});

        setState(() {
          userData?['profileImageUrl'] = downloadUrl;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
              Text('เกิดข้อผิดพลาดในการอัพโหลดรูปภาพ กรุณาลองใหม่อีกครั้ง')),
        );
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'เกิดข้อผิดพลาดในการบันทึกการตั้งค่า กรุณาลองใหม่อีกครั้ง')),
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการลบบัญชี'),
          content: const Text(
              'คุณแน่ใจหรือไม่ที่จะลบบัญชีผู้ใช้งาน? การกระทำนี้ไม่สามารถยกเลิกได้'),
          actions: <Widget>[
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('ยืนยัน'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .delete();
          await FirebaseFirestore.instance
              .collection('profiles')
              .doc(user.uid)
              .delete();

          final storageRef = FirebaseStorage.instance
              .ref()
              .child('profile_images')
              .child('${user.uid}.jpg');
          try {
            await storageRef.getDownloadURL();
            await storageRef.delete();
          } catch (e) {
            if (e is FirebaseException && e.code == 'object-not-found') {
              // ไม่ต้องทำอะไรถ้าไม่พบรูปภาพ
            }
          }

          await user.delete();
          await FirebaseAuth.instance.signOut();

          Navigator.of(context)
              .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('เกิดข้อผิดพลาดในการลบบัญชี กรุณาลองใหม่อีกครั้ง')),
        );
      }
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
                  _maskEmail(FirebaseAuth.instance.currentUser?.email ??
                      'เกิดข้อผิดพลาดในการดึงข้อมูล!')),
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
        onPressed: _showReportProblemDialog,
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
            onStateChanged: (isDarkModeEnabled) async {
              themeProvider.toggleTheme(isDarkModeEnabled);
              await _toggleDisplayMode(isDarkModeEnabled);
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
          child: _buildButton('แก้ไขเพื่อน', onPressed: () {
            // TODO: Implement friend management functionality
          }),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildButton('จัดการบัญชี', onPressed: () {
            _showManageAccountDialog();
          }),
        ),
      ],
    );
  }

  Widget _buildButton(String label, {required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.grey),
        ),
      ),
      onPressed: onPressed,
      child: Text(label, style: AppTextStyles.inputText),
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