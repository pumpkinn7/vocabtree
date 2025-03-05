import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:provider/provider.dart';
import 'package:vocabtree/core/theme/theme_provider.dart';
import 'package:vocabtree/features/profile/models/profile_model.dart';
import 'package:vocabtree/features/profile/services/profile_service.dart';
import 'package:vocabtree/features/profile/screens/edit_friend_screen.dart';
import 'package:vocabtree/features/profile/widgets/dialogs/password_confirm_dialog.dart';
import 'package:vocabtree/features/profile/widgets/display_mode_switch.dart';
import 'package:vocabtree/features/profile/widgets/profile_actions.dart';
import 'package:vocabtree/features/profile/widgets/profile_header.dart';
import 'package:vocabtree/features/profile/widgets/profile_info.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  late Future<ProfileModel> _profileFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = _profileService.loadUserProfile();
  }

  Future<void> _uploadProfileImage(File imageFile) async {
    try {
      setState(() => _isLoading = true);
      await _profileService.uploadProfileImage(imageFile);
      setState(() {
        _profileFuture = _profileService.loadUserProfile();
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('อัปโหลดรูปภาพสำเร็จ')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'เกิดข้อผิดพลาดในการอัพโหลดรูปภาพ กรุณาลองใหม่อีกครั้ง')),
        );
      }
    }
  }

  Future<void> _handleResetPasswordAndSignOut() async {
    final result = await Navigator.pushNamed(context, '/reset-password');
    if (result == true) {
      try {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('คำขอรีเซ็ตรหัสผ่านถูกส่งแล้ว กรุณาตรวจสอบอีเมลของคุณ'),
            ),
          );
          Navigator.of(context).pushReplacementNamed('/login');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('เกิดข้อผิดพลาดในการออกจากระบบ กรุณาลองใหม่อีกครั้ง')),
          );
        }
      }
    }
  }

  Future<void> _deleteAccount() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่พบข้อมูลผู้ใช้')),
        );
        return;
      }

      bool? confirmDelete = await showDialog<bool>(
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
                child:
                    const Text('ยืนยัน', style: TextStyle(color: Colors.red)),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );

      if (confirmDelete == true) {
        bool isReauthenticated = await _promptForPassword();
        if (!isReauthenticated) return;

        bool success = await _profileService.deleteUserAccount(user.uid);

        if (success && mounted) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/login', (route) => false);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('เกิดข้อผิดพลาดในการลบบัญชี กรุณาลองใหม่อีกครั้ง')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('เกิดข้อผิดพลาดในการลบบัญชี กรุณาลองใหม่อีกครั้ง')),
      );
    }
  }

  Future<bool> _promptForPassword() async {
    String? password;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PasswordConfirmDialog(
        onConfirm: (value) => password = value,
      ),
    );

    if (password != null && password!.isNotEmpty) {
      return await _profileService.reauthenticateUser(password!);
    }
    return false;
  }

  void _navigateToEditFriend() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              EditFriendScreen(currentUserId: currentUser.uid),
        ),
      );
    }
  }

  Future<void> _signOut() async {
    try {
      await _profileService.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เกิดข้อผิดพลาดในการออกจากระบบ กรุณาลองใหม่อีกครั้ง'),
          ),
        );
      }
    }
  }

  Future<void> _toggleDisplayMode(bool isDarkMode) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.toggleTheme(isDarkMode);

    try {
      await _profileService.toggleDisplayMode(isDarkMode);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'เกิดข้อผิดพลาดในการบันทึกการตั้งค่า กรุณาลองใหม่อีกครั้ง'),
          ),
        );
      }
    }
  }

  void _showManageAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('จัดการบัญชี'),
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
              child: const Text('ฉันลืมรหัสผ่าน'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteAccount();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('ลบบัญชีผู้ใช้งาน'),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('ปิด'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: FutureBuilder<ProfileModel>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                _isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return const Center(child: Text('ไม่พบข้อมูลผู้ใช้'));
            }

            final profile = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BootstrapContainer(
                fluid: true,
                children: [
                  BootstrapRow(
                    children: [
                      BootstrapCol(
                        sizes: 'col-xs-12 col-sm-12 col-md-8 col-lg-6 col-xl-6',
                        offsets:
                            'offset-xs-0 offset-sm-0 offset-md-2 offset-lg-3 offset-xl-3',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 50),
                            ProfileHeader(
                              profile: profile,
                              onImageSelected: _uploadProfileImage,
                            ),
                            const SizedBox(height: 30),
                            ProfileInfo(profile: profile),
                            const SizedBox(height: 30),
                            DisplayModeSwitch(
                              isDarkMode:
                                  themeProvider.themeMode == ThemeMode.dark,
                              onToggle: _toggleDisplayMode,
                            ),
                            const SizedBox(height: 20),
                            ProfileActions(
                              onEditFriends: _navigateToEditFriend,
                              onManageAccount: _showManageAccountDialog,
                              onSignOut: _signOut,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
