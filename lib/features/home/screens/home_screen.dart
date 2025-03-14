import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:vocabtree/core/theme/text_styles.dart';

import '../widgets/profile_card.dart';
import '../widgets/profile_page_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  late final PageController _pageController;
  int _currentPage = 0;

  String username = '';
  DateTime? createdAt;
  String profileImageUrl = '';
  Map<String, dynamic> userUnlockedTopics = {};
  int userRewardCount = 0;

  List<Map<String, dynamic>> friendList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _fetchData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (currentUser == null) {
      setState(() => isLoading = false);
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

      // ดึงเพื่อน
      final friendsDoc = await FirebaseFirestore.instance
          .collection('friends')
          .doc(userId)
          .get();
      final friendIds = (friendsDoc.data()?['friends'] as List<dynamic>? ?? []);

      // ดึงข้อมูลเพื่อน
      List<Map<String, dynamic>> tempFriendList = [];
      for (var fid in friendIds) {
        // ข้อมูลพื้นฐานของเพื่อน
        final friendUserDoc =
            await FirebaseFirestore.instance.collection('users').doc(fid).get();
        if (!friendUserDoc.exists) continue;
        final fData = friendUserDoc.data() ?? {};

        // createdAt เพื่อน
        DateTime? friendCreatedAt;
        final friendProfileDoc = await FirebaseFirestore.instance
            .collection('profiles')
            .doc(fid)
            .get();
        if (friendProfileDoc.exists) {
          final ts = friendProfileDoc.data()?['createdAt'] as Timestamp?;
          if (ts != null) friendCreatedAt = ts.toDate();
        }

        // unlockedTopics เพื่อน
        final friendProgressDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(fid)
            .collection('progress')
            .doc('unlockedTopics')
            .get();

        // reward เพื่อน
        final friendRewardsSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(fid)
            .collection('rewards')
            .get();

        tempFriendList.add({
          'userId': fid,
          'username': fData['username'] ?? 'No Name',
          'createdAt': friendCreatedAt,
          'profileImageUrl': fData['profileImageUrl'] ?? '',
          'unlockedTopics': friendProgressDoc.data() ?? {},
          'rewardCount': friendRewardsSnap.size,
        });
      }

      setState(() {
        friendList = tempFriendList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getBackgroundImage(Map<String, dynamic> unlockedTopics) {
    if ((unlockedTopics['C2'] ?? {}).containsValue(true)) {
      return 'assets/images/winter.png';
    }
    if ((unlockedTopics['C1'] ?? {}).containsValue(true)) {
      return 'assets/images/autumn.png';
    }
    if ((unlockedTopics['B2'] ?? {}).containsValue(true)) {
      return 'assets/images/summer.png';
    }
    return 'assets/images/spring.png';
  }

  @override
  Widget build(BuildContext context) {
    bootstrapGridParameters(gutterSize: 16);

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('หน้าหลัก', style: AppTextStyles.headline),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final List<Map<String, dynamic>> pagesData = [
      {
        'username': username,
        'createdAt': createdAt,
        'profileImageUrl': profileImageUrl,
        'unlockedTopics': userUnlockedTopics,
        'isUser': true,
        'rewardCount': userRewardCount,
      },
      ...friendList.map((f) => {
            'username': f['username'],
            'createdAt': f['createdAt'],
            'profileImageUrl': f['profileImageUrl'],
            'unlockedTopics': f['unlockedTopics'] ?? {},
            'isUser': false,
            'rewardCount': f['rewardCount'] ?? 0,
          }),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('หน้าหลัก', style: AppTextStyles.headline),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemCount: pagesData.length,
              itemBuilder: (context, index) {
                final data = pagesData[index];
                final isCurrentPage = index == _currentPage;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: EdgeInsets.symmetric(
                    vertical: isCurrentPage ? 10 : 20,
                    horizontal: 8,
                  ),
                  child: ProfileCard(
                    username: data['username'],
                    joinedAt: data['createdAt'],
                    profileImageUrl: data['profileImageUrl'],
                    isUser: data['isUser'],
                    unlockedTopics: data['unlockedTopics'],
                    backgroundImage:
                        _getBackgroundImage(data['unlockedTopics']),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ProfilePageIndicator(
            currentPage: _currentPage,
            totalPages: pagesData.length,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
