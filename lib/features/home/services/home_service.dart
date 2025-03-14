import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile_model.dart';

class HomeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<UserProfileModel> fetchCurrentUser() async {
    if (currentUser == null) {
      throw Exception('ไม่พบข้อมูลการเข้าสู่ระบบ');
    }

    final userId = currentUser!.uid;

    // ดึงข้อมูล user
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final username = userDoc.data()?['username'] ?? 'ไม่มีชื่อ';
    final profileImageUrl = userDoc.data()?['profileImageUrl'] ?? '';

    // ดึงวันที่เข้าร่วม
    final profileDoc =
        await _firestore.collection('profiles').doc(userId).get();
    DateTime? createdAt;
    if (profileDoc.exists) {
      final ts = profileDoc.data()?['createdAt'] as Timestamp?;
      if (ts != null) {
        createdAt = ts.toDate();
      }
    }

    // ดึงข้อมูลหัวข้อที่ปลดล็อคแล้ว
    final progressDoc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('progress')
        .doc('unlockedTopics')
        .get();
    final unlockedTopics = progressDoc.data() ?? {};

    // ดึงจำนวนรางวัล
    final rewardsSnap = await _firestore
        .collection('users')
        .doc(userId)
        .collection('rewards')
        .get();
    final rewardCount = rewardsSnap.size;

    return UserProfileModel(
      username: username,
      createdAt: createdAt,
      profileImageUrl: profileImageUrl,
      unlockedTopics: unlockedTopics,
      isUser: true,
      rewardCount: rewardCount,
    );
  }

  Future<List<UserProfileModel>> fetchFriends() async {
    if (currentUser == null) {
      return [];
    }

    final userId = currentUser!.uid;

    // ดึงรายการเพื่อน
    final friendsDoc = await _firestore.collection('friends').doc(userId).get();
    final friendIds = (friendsDoc.data()?['friends'] as List<dynamic>? ?? []);

    List<UserProfileModel> friendList = [];

    for (var fid in friendIds) {
      // ข้อมูลพื้นฐานของเพื่อน
      final friendUserDoc = await _firestore.collection('users').doc(fid).get();
      if (!friendUserDoc.exists) continue;

      final username = friendUserDoc.data()?['username'] ?? 'ไม่มีชื่อ';
      final profileImageUrl = friendUserDoc.data()?['profileImageUrl'] ?? '';

      // ดึงวันที่เพื่อนเข้าร่วม
      DateTime? friendCreatedAt;
      final friendProfileDoc =
          await _firestore.collection('profiles').doc(fid).get();
      if (friendProfileDoc.exists) {
        final ts = friendProfileDoc.data()?['createdAt'] as Timestamp?;
        if (ts != null) {
          friendCreatedAt = ts.toDate();
        }
      }

      // ดึงหัวข้อที่เพื่อนปลดล็อค
      final friendProgressDoc = await _firestore
          .collection('users')
          .doc(fid)
          .collection('progress')
          .doc('unlockedTopics')
          .get();
      final unlockedTopics = friendProgressDoc.data() ?? {};

      // ดึงรางวัลของเพื่อน
      final friendRewardsSnap = await _firestore
          .collection('users')
          .doc(fid)
          .collection('rewards')
          .get();
      final rewardCount = friendRewardsSnap.size;

      friendList.add(UserProfileModel(
        username: username,
        createdAt: friendCreatedAt,
        profileImageUrl: profileImageUrl,
        unlockedTopics: unlockedTopics,
        isUser: false,
        rewardCount: rewardCount,
      ));
    }

    return friendList;
  }
}
