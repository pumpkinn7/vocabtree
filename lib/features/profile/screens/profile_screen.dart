import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vocabtree/core/theme/theme_provider.dart';
import 'package:vocabtree/features/profile/models/profile_model.dart';
import 'package:vocabtree/features/profile/services/profile_service.dart';
import 'package:vocabtree/features/profile/screens/edit_friend_screen.dart';
import 'package:vocabtree/features/profile/widgets/dialogs/password_confirm_dialog.dart';
import 'package:vocabtree/features/profile/widgets/dialogs/manage_account_dialog.dart';
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

  Future<void> _uploadProfileImage(XFile imageFile) async {
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
        if (!isReauthenticated) {
          // เพิ่มแจ้งเตือนเมื่อยืนยันตัวตนไม่สำเร็จ (รหัสผ่านผิด)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('รหัสผ่านไม่ถูกต้อง กรุณาลองใหม่อีกครั้ง'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // แสดง loading indicator ขณะกำลังลบบัญชี
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('กำลังลบบัญชีผู้ใช้...'),
              duration: Duration(seconds: 2),
            ),
          );
        }

        bool success = await _profileService.deleteUserAccount(user.uid);

        if (success && mounted) {
          // แสดงแจ้งเตือนเมื่อลบบัญชีสำเร็จ
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ลบบัญชีสำเร็จแล้ว'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/login', (route) => false);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('เกิดข้อผิดพลาดในการลบบัญชี กรุณาลองใหม่อีกครั้ง'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('เกิดข้อผิดพลาด: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<bool> _promptForPassword() async {
    String? password = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return PasswordConfirmDialog(
          onConfirm: (String password) {
            Navigator.of(context).pop(password);
          },
        );
      },
    );

    if (password != null && password.isNotEmpty) {
      return await _profileService.reauthenticateUser(password);
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
      builder: (BuildContext dialogContext) => ManageAccountDialog(
        onResetPasswordPressed: () {
          Navigator.of(dialogContext).pop();
          _handleResetPasswordAndSignOut();
        },
        onDeleteAccountPressed: () {
          Navigator.of(dialogContext).pop();
          _deleteAccount();
        },
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

            return Center(
              // เพิ่ม Center widget ที่นี่
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  // เพิ่ม ConstrainedBox เพื่อให้ content มีความสูงอย่างน้อยเท่ากับ viewport
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center, // นื้อหาตรงกลางในแนวตั้ง
                    child: BootstrapContainer(
                      fluid: true,
                      children: [
                        BootstrapRow(
                          children: [
                            BootstrapCol(
                              sizes:
                                  'col-xs-12 col-sm-12 col-md-8 col-lg-4 col-xl-4',
                              offsets:
                                  'offset-xs-0 offset-sm-0 offset-md-2 offset-lg-4 offset-xl-4',
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // จัดให้เนื้อหาอยู่ตรงกลางในแนวตั้ง
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ProfileHeader(
                                    profile: profile,
                                    onImageSelected: _uploadProfileImage,
                                  ),
                                  const SizedBox(height: 15),
                                  ProfileInfo(profile: profile),
                                  const SizedBox(height: 15),
                                  DisplayModeSwitch(
                                    isDarkMode: themeProvider.themeMode ==
                                        ThemeMode.dark,
                                    onToggle: _toggleDisplayMode,
                                  ),
                                  const SizedBox(height: 15),
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
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
