import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  final String? userId;
  final String? username;
  final String? email;
  final String? profileImageUrl;
  final Timestamp? createdAt;
  final Map<String, dynamic>? settings;

  ProfileModel({
    this.userId,
    this.username,
    this.email,
    this.profileImageUrl,
    this.createdAt,
    this.settings,
  });

  factory ProfileModel.fromFirestore(Map<String, dynamic>? userData,
      Map<String, dynamic>? profileData, String? email) {
    return ProfileModel(
      userId: userData?['uid'],
      username: profileData?['username'] ?? 'ไม่พบชื่อผู้ใช้',
      email: email,
      profileImageUrl: userData?['profileImageUrl'],
      createdAt: profileData?['createdAt'],
      settings: profileData?['settings'],
    );
  }

  String getMaskedEmail() {
    if (email == null || email!.isEmpty) return '';
    final parts = email!.split('@');
    if (parts.length != 2) return email!;
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

  String getFormattedDate() {
    if (createdAt == null) return 'ไม่ทราบ';
    DateTime date = createdAt!.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
}
