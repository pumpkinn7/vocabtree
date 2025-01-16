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

  // ข้อมูลผู้ใช้
  String username = '';
  DateTime? createdAt;
  String profileImageUrl = '';

  // รายชื่อเพื่อนดึงจาก Firestore
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
        errorMessage = 'ผู้ใช้งานยังไม่ได้เข้าสู่ระบบ';
      });
      return;
    }

    try {
      final userId = currentUser!.uid;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data() ?? {};
        username = data['username'] ?? 'No Username';
        profileImageUrl = data['profileImageUrl'] ?? '';
      }

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

      // ดึงเพื่อนจาก /friends/{userId}
      final friendsDoc = await FirebaseFirestore.instance
          .collection('friends')
          .doc(userId)
          .get();


      final friendIds =
      (friendsDoc.data()?['friends'] as List<dynamic>? ?? []);

      // วนลูปดึงข้อมูลเพื่อนทั้งหมด อันนี้อย่าพึ่งลบ
      List<Map<String, dynamic>> tempFriendList = [];
      for (var fid in friendIds) {
        final friendUserDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(fid)
            .get();
        if (!friendUserDoc.exists) continue;
        final fData = friendUserDoc.data() ?? {};

        // ดึงข้อมูลจาก profiles collection รับ createdAt เพื่อน
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

        tempFriendList.add({
          'userId': fid,
          'username': fData['username'] ?? 'No Name',
          'createdAt': friendCreatedAt,
          'profileImageUrl': fData['profileImageUrl'] ?? '',
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

    // รวมข้อมูลผู้ใช้ไว้ List กับเพื่อน
    final List<Map<String, dynamic>> pagesData = [
      {
        'username': username,
        'createdAt': createdAt,
        'profileImageUrl': profileImageUrl,
      },
      ...friendList,
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
                );
              },
              viewportFraction: 0.8,
              scale: 0.9,
              loop: true, // เลื่อนวนลูป
            ),
          ),
        ],
      ),
    );
  }
}