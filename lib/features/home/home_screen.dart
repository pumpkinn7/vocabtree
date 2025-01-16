import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:card_swiper/card_swiper.dart';

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

  // รายชื่อเพื่อน (ดึงจาก Firestore)
  List<Map<String, dynamic>> friendList = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  /// ฟังก์ชันหลักในการดึงข้อมูลผู้ใช้และเพื่อนจาก Firebase
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

      // 1) ดึงข้อมูลผู้ใช้จาก users collection
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data() ?? {};
        username = data['username'] ?? 'No Username';
        profileImageUrl = data['profileImageUrl'] ?? '';
      }

      // 2) ดึงข้อมูลจาก profiles collection เพื่อรับ createdAt
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

      // 3) ดึงข้อมูลเพื่อนจาก /friends/{userId}
      final friendsDoc = await FirebaseFirestore.instance
          .collection('friends')
          .doc(userId)
          .get();

      // friendIds คือ array ของ userId เพื่อนแต่ละคน
      final friendIds = (friendsDoc.data()?['friends'] as List<dynamic>? ?? []);

      // วนลูปดึงข้อมูลแต่ละเพื่อน
      List<Map<String, dynamic>> tempFriendList = [];
      for (var fid in friendIds) {
        final friendUserDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(fid)
            .get();
        if (!friendUserDoc.exists) continue;
        final fData = friendUserDoc.data() ?? {};

        // ดึงข้อมูลจาก profiles collection เพื่อรับ createdAt ของเพื่อน
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
          'createdAt': friendCreatedAt, // เป็น DateTime? แล้ว
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

  /// สร้างหน้า UI โดยใช้ CardSwiper
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

    // สร้างรายการ Page (profile) ที่ต้องการแสดง
    final List<Map<String, dynamic>> pagesData = [
      {
        'username': username,
        'createdAt': createdAt,
        'profileImageUrl': profileImageUrl,
      },
      ...friendList, // เอาเพื่อนมาต่อท้าย
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Swiper ส่วนหลัก
          Expanded(
            child: Swiper(
              itemCount: pagesData.length,
              itemBuilder: (BuildContext context, int index) {
                final data = pagesData[index];
                return _buildProfileCard(
                  data['username'] ?? 'No Name',
                  data['createdAt'] as DateTime?,
                  data['profileImageUrl'] ?? '',
                );
              },
              viewportFraction: 0.8,
              scale: 0.9,
              loop: true, // เลื่อนได้แบบวนลูป
              // ลบ SwiperPagination ออก
              // pagination: const SwiperPagination(
              //   builder: DotSwiperPaginationBuilder(
              //     activeColor: Colors.blueGrey,
              //     color: Colors.grey,
              //     size: 8,
              //     activeSize: 8,
              //   ),
              // ),
            ),
          ),

          // ลบ Row สำหรับ dot indicators ออกแล้ว เพราะเราไม่ต้องการให้แสดง
        ],
      ),
    );
  }

  /// สร้าง Card สำหรับแสดงข้อมูลโปรไฟล์แต่ละคน
  Widget _buildProfileCard(String name, DateTime? joinedAt, String imageUrl) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // รูปโปรไฟล์
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
              child: imageUrl.isEmpty
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              joinedAt != null
                  ? 'เข้าร่วมเมื่อ: ${joinedAt.day}/${joinedAt.month}/${joinedAt.year}'
                  : 'ไม่ทราบวันที่เข้าร่วม',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
