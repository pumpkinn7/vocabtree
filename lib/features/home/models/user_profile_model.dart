class UserProfileModel {
  final String username;
  final DateTime? createdAt;
  final String profileImageUrl;
  final Map<String, dynamic> unlockedTopics;
  final bool isUser;
  final int rewardCount;

  UserProfileModel({
    required this.username,
    this.createdAt,
    required this.profileImageUrl,
    required this.unlockedTopics,
    required this.isUser,
    required this.rewardCount,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      username: map['username'] ?? 'ไม่มีชื่อ',
      createdAt: map['createdAt'],
      profileImageUrl: map['profileImageUrl'] ?? '',
      unlockedTopics: map['unlockedTopics'] ?? {},
      isUser: map['isUser'] ?? false,
      rewardCount: map['rewardCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'createdAt': createdAt,
      'profileImageUrl': profileImageUrl,
      'unlockedTopics': unlockedTopics,
      'isUser': isUser,
      'rewardCount': rewardCount,
    };
  }
}
