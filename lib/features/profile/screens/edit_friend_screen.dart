import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/text_styles.dart';
import '../services/friend_service.dart';
import '../widgets/search_tab.dart';
import '../widgets/received_requests_tab.dart';
import '../widgets/sent_requests_tab.dart';
import '../widgets/my_friends_tab.dart';
import '../widgets/notification_dot.dart';

class EditFriendScreen extends StatefulWidget {
  const EditFriendScreen({super.key, required this.currentUserId});

  final String currentUserId;

  @override
  State<EditFriendScreen> createState() => _EditFriendScreenState();
}

class _EditFriendScreenState extends State<EditFriendScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final FriendService _friendService;

  // Streams สำหรับแจ้งเตือน
  Stream<QuerySnapshot>? _receivedRequestsStream;
  Stream<QuerySnapshot>? _sentRequestsStream;
  Stream<DocumentSnapshot>? _friendsListStream;

  int _receivedRequestsCount = 0;
  int _sentRequestsCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _friendService = FriendService();

    // กำหนด streams ติดตามการเปลี่ยนแปลง
    _receivedRequestsStream =
        _friendService.getReceivedFriendRequests(widget.currentUserId);
    _sentRequestsStream =
        _friendService.getSentFriendRequests(widget.currentUserId);
    _friendsListStream = _friendService.getFriendsList(widget.currentUserId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'จัดการเพื่อน',
          style: AppTextStyles.title,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: AppTextStyles.label,
          tabs: [
            const Tab(text: 'ค้นหา'),
            // แท็บคำขอ / จุดแจ้งเตือน
            StreamBuilder<QuerySnapshot>(
                stream: _receivedRequestsStream,
                builder: (context, snapshot) {
                  bool showDot = false;
                  if (snapshot.hasData) {
                    _receivedRequestsCount = snapshot.data!.docs.length;
                    showDot = _receivedRequestsCount > 0;
                  }
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('คำขอ'),
                      NotificationDot(showDot: showDot),
                    ],
                  );
                }),
            // แท็บส่งคำขอพ / แจ้งเตือน
            StreamBuilder<QuerySnapshot>(
                stream: _sentRequestsStream,
                builder: (context, snapshot) {
                  bool showDot = false;
                  if (snapshot.hasData) {
                    _sentRequestsCount = snapshot.data!.docs.length;
                    showDot = _sentRequestsCount > 0;
                  }
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('ส่งคำขอ'),
                      NotificationDot(showDot: showDot),
                    ],
                  );
                }),
            // แท็บรายชื่อ / จุดแจ้งเตือน
            StreamBuilder<DocumentSnapshot>(
                stream: _friendsListStream,
                builder: (context, snapshot) {
                  bool showDot = false;
                  if (snapshot.hasData && snapshot.data!.exists) {
                    List<dynamic> friends = snapshot.data!.get('friends') ?? [];
                    showDot = friends.isNotEmpty;
                  }
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('รายชื่อ'),
                      NotificationDot(showDot: showDot),
                    ],
                  );
                }),
          ],
        ),
      ),
      body: BootstrapContainer(
        fluid: true,
        children: [
          BootstrapRow(
            children: [
              BootstrapCol(
                sizes: 'col-12',
                child: SizedBox(
                  height: MediaQuery.of(context).size.height -
                      AppBar().preferredSize.height -
                      MediaQuery.of(context).padding.top -
                      kTextTabBarHeight,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      SearchTab(
                        currentUserId: widget.currentUserId,
                        friendService: _friendService,
                      ),
                      ReceivedRequestsTab(
                        currentUserId: widget.currentUserId,
                        friendService: _friendService,
                      ),
                      SentRequestsTab(
                        currentUserId: widget.currentUserId,
                        friendService: _friendService,
                      ),
                      MyFriendsTab(
                        currentUserId: widget.currentUserId,
                        friendService: _friendService,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
