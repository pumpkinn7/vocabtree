// lib/pages/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../quiz/model/user_progress_model.dart';
import '../quiz/services/firebase_service.dart';

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

  // ความคืบหน้าของผู้ใช้ (เช่น ปลดล็อกกี่หัวข้อในแต่ละ CEFR)
  UserProgressModel? userProgress;

  // รายชื่อเพื่อน (ดึงจาก Firestore)
  List<Map<String, dynamic>> friendList = [];

  bool isLoading = true;
  String? errorMessage;

  // สำหรับจับคู่ฤดูกาล <-> CEFR Level
  final Map<String, String> seasonCefrMap = {
    'Spring': 'B1',
    'Summer': 'B2',
    'Autumn': 'C1',
    'Winter': 'C2',
  };

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

      // 3) ดึงความคืบหน้าผู้ใช้ (unlockedTopics)
      final progressDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('progress')
          .doc('unlockedTopics')
          .get();

      if (progressDoc.exists) {
        userProgress = UserProgressModel.fromMap(progressDoc.data() ?? {});
      } else {
        // ถ้าไม่มีเอกสารนี้ อาจกำหนดค่า default
        userProgress = UserProgressModel(
          highestUnlockedLevel: 'B1',
          passedTopicsCount: {},
          topicUnlockStatus: {},
        );
      }

      // 4) ดึงข้อมูลเพื่อนจาก /friends/{userId}
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

        // ดึงความคืบหน้าของเพื่อนแต่ละคน
        final friendProgressDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(fid)
            .collection('progress')
            .doc('unlockedTopics')
            .get();

        UserProgressModel? fProgress;
        if (friendProgressDoc.exists) {
          fProgress = UserProgressModel.fromMap(friendProgressDoc.data() ?? {});
        } else {
          fProgress = UserProgressModel(
            highestUnlockedLevel: 'B1',
            passedTopicsCount: {},
            topicUnlockStatus: {},
          );
        }

        tempFriendList.add({
          'userId': fid,
          'username': fData['username'] ?? 'No Name',
          'createdAt': friendCreatedAt, // เป็น DateTime? แล้ว
          'profileImageUrl': fData['profileImageUrl'] ?? '',
          'progress': fProgress,
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

  /// สร้าง PageView โดย
  /// - หน้าแรก (index == 0) = User Page
  /// - หน้าถัดไป (index >= 1) = Friend Page ของแต่ละคน
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

    // จำนวนหน้าทั้งหมด = 1 (ผู้ใช้) + friendList.length
    final pageCount = friendList.length + 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: PageView.builder(
        itemCount: pageCount,
        itemBuilder: (context, index) {
          if (index == 0) {
            // หน้าแรกเป็น User Page
            return _buildUserPage();
          } else {
            // หน้าถัดไปเป็น Friend Page
            final friend = friendList[index - 1];
            return _buildFriendPage(friend);
          }
        },
      ),
    );
  }

  /// ส่วน UI ของ User Page
  Widget _buildUserPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // รูปโปรไฟล์
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            backgroundImage:
            profileImageUrl.isNotEmpty ? NetworkImage(profileImageUrl) : null,
            child:
            profileImageUrl.isEmpty ? const Icon(Icons.person, size: 40) : null,
          ),
          const SizedBox(height: 16),
          Text(
            username,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            createdAt != null
                ? 'เข้าร่วมเมื่อ: ${createdAt!.day}/${createdAt!.month}/${createdAt!.year}'
                : 'ไม่ทราบวันที่เข้าร่วม',
          ),
          const SizedBox(height: 16),
          // ข้อความความสำเร็จ
          Text(
            'ครอบครอง: ${_sumPassedTopics(userProgress)} ต้นไม้',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          // แสดงจำนวนหัวข้อที่ปลดล็อกตามฤดูกาล
          _buildSeasonCefrWidget(userProgress),
        ],
      ),
    );
  }

  /// ส่วน UI ของ Friend Page
  Widget _buildFriendPage(Map<String, dynamic> friend) {
    final friendUsername = friend['username'] as String? ?? 'No Name';
    final friendProfile = friend['profileImageUrl'] as String? ?? '';
    final friendCreatedAt = friend['createdAt'] as DateTime?;
    final friendProgress = friend['progress'] as UserProgressModel?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // รูปโปรไฟล์เพื่อน
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            backgroundImage:
            friendProfile.isNotEmpty ? NetworkImage(friendProfile) : null,
            child: friendProfile.isEmpty
                ? const Icon(Icons.person, size: 40)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            friendUsername,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            friendCreatedAt != null
                ? 'เข้าร่วมเมื่อ: ${friendCreatedAt.day}/${friendCreatedAt.month}/${friendCreatedAt.year}'
                : 'ไม่ทราบวันที่เข้าร่วม',
          ),
          const SizedBox(height: 16),
          // ข้อความความสำเร็จ
          Text(
            'ครอบครอง: ${_sumPassedTopics(friendProgress)} ต้นไม้',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          // หัวข้อ CEFR ตามฤดูกาล
          _buildSeasonCefrWidget(friendProgress),
        ],
      ),
    );
  }

  /// แสดงข้อมูลหัวข้อ CEFR ตามฤดูกาล (Spring, Summer, Autumn, Winter)
  Widget _buildSeasonCefrWidget(UserProgressModel? progress) {
    if (progress == null) {
      return const Text('ไม่พบข้อมูลความคืบหน้า');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: seasonCefrMap.entries.map((entry) {
        final season = entry.key;      // Spring, Summer, Autumn, Winter
        final cefrLevel = entry.value; // B1, B2, C1, C2

        // ดึงจำนวนที่ผ่านแล้ว
        final unlockedCount = progress.passedTopicsCount[cefrLevel] ?? 0;
        // ดึงหัวข้อทั้งหมดในระดับนี้ จาก FirebaseService
        final totalTopics = FirebaseService.cefrTopics[cefrLevel]?.length ?? 0;

        return Text('$season: $unlockedCount of $totalTopics');
      }).toList(),
    );
  }

  /// รวมจำนวน topic ที่ผ่านทั้งหมดใน passedTopicsCount
  int _sumPassedTopics(UserProgressModel? progress) {
    if (progress == null) return 0;
    // สมมุติว่าใน passedTopicsCount เราเก็บเป็น {'B1': 3, 'B2': 1, ...}
    // ก็รวมทุกค่า
    return progress.passedTopicsCount.values.fold(0, (a, b) => a + b);
  }
}
