class FriendModel {
  final String userId;
  final String name;
  final String email;
  final String profileImage;

  FriendModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.profileImage,
  });

  factory FriendModel.fromMap(Map<String, dynamic> map, String docId) {
    return FriendModel(
      userId: docId,
      name: map['username'] ?? '',
      email: map['email'] ?? '',
      profileImage: map['profileImageUrl'] ?? '',
    );
  }

  factory FriendModel.fromSearchMap(Map<String, dynamic> map) {
    return FriendModel(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profileImage: map['profileImage'] ?? '',
    );
  }
}
