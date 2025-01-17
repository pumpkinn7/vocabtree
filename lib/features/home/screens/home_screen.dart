import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:card_swiper/card_swiper.dart';

import '../widgets/profile_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  String username = '';
  DateTime? createdAt;
  String profileImageUrl = '';
  Map<String, dynamic> userUnlockedTopics = {};
  int userRewardCount = 0;

  List<Map<String, dynamic>> friendList = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (currentUser == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'ยังมั่ยยได้เข้าสู่ระบบบ';
      });
      return;
    }

    try {
      final userId = currentUser!.uid;

      // ดึงข้อมูล user
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data() ?? {};
        username = data['username'] ?? 'No Username';
        profileImageUrl = data['profileImageUrl'] ?? '';
      }

      // ดึง profiles รับค่า createdAt
      final profileDoc = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(userId)
          .get();
      if (profileDoc.exists) {
        final pData = profileDoc.data() ?? {};
        final ts = pData['createdAt'] as Timestamp?;
        if (ts != null) {
          createdAt = ts.toDate();
        }
      }

      // ดึง progress/unlockedTopics ของ user
      final progressDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('progress')
          .doc('unlockedTopics')
          .get();
      userUnlockedTopics = progressDoc.data() ?? {};

      // ดึง reward ของ user
      final rewardsSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('rewards')
          .get();
      userRewardCount = rewardsSnap.size;

      // ดึงเพื่อน /friends/{userId}
      final friendsDoc = await FirebaseFirestore.instance
          .collection('friends')
          .doc(userId)
          .get();
      final friendIds =
      (friendsDoc.data()?['friends'] as List<dynamic>? ?? []);

      List<Map<String, dynamic>> tempFriendList = [];
      for (var fid in friendIds) {
        // ข้อมูลพื้นฐานของเพื่อน
        final friendUserDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(fid)
            .get();
        if (!friendUserDoc.exists) continue;
        final fData = friendUserDoc.data() ?? {};

        // createdAt เพื่อน
        final friendProfileDoc = await FirebaseFirestore.instance
            .collection('profiles')
            .doc(fid)
            .get();
        DateTime? friendCreatedAt;
        if (friendProfileDoc.exists) {
          final fpData = friendProfileDoc.data() ?? {};
          final ts = fpData['createdAt'] as Timestamp?;
          if (ts != null) {
            friendCreatedAt = ts.toDate();
          }
        }

        // unlockedTopics เพื่อน
        final friendProgressDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(fid)
            .collection('progress')
            .doc('unlockedTopics')
            .get();
        final friendUnlockedTopics = friendProgressDoc.data() ?? {};

        // reward เพื่อน
        final friendRewardsSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(fid)
            .collection('rewards')
            .get();
        final friendRewardCount = friendRewardsSnap.size;

        tempFriendList.add({
          'userId': fid,
          'username': fData['username'] ?? 'No Name',
          'createdAt': friendCreatedAt,
          'profileImageUrl': fData['profileImageUrl'] ?? '',
          'unlockedTopics': friendUnlockedTopics,
          'rewardCount': friendRewardCount,
        });
      }

      setState(() {
        friendList = tempFriendList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Home Screen')),
        body: Center(child: Text(errorMessage!)),
      );
    }

    final List<Map<String, dynamic>> pagesData = [
      {
        'username': username,
        'createdAt': createdAt,
        'profileImageUrl': profileImageUrl,
        'unlockedTopics': userUnlockedTopics,
        'isUser': true,
        'rewardCount': userRewardCount, // user
      },
      ...friendList.map((f) {
        return {
          'username': f['username'],
          'createdAt': f['createdAt'],
          'profileImageUrl': f['profileImageUrl'],
          'unlockedTopics': f['unlockedTopics'] ?? {},
          'isUser': false,
          'rewardCount': f['rewardCount'] ?? 0,
        };
      }),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: Swiper(
              itemCount: pagesData.length,
              itemBuilder: (BuildContext context, int index) {
                final data = pagesData[index];
                return ProfileCard(
                  name: data['username'] ?? 'No Name',
                  joinedAt: data['createdAt'] as DateTime?,
                  imageUrl: data['profileImageUrl'] ?? '',
                  unlockedTopics: data['unlockedTopics'] as Map<String, dynamic>? ?? {},
                  isUser: data['isUser'] as bool? ?? false,
                  // ส่ง rewardCount ให้ ProfileCard
                  rewardCount: data['rewardCount'] as int? ?? 0,
                );
              },
              viewportFraction: 0.8,
              scale: 0.9,
              loop: true,
            ),
          ),
        ],
      ),
    );
  }
}