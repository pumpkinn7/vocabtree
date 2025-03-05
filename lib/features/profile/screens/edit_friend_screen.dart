import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';

import '../../../core/theme/text_styles.dart';
import '../services/friend_service.dart';
import '../widgets/search_tab.dart';
import '../widgets/received_requests_tab.dart';
import '../widgets/sent_requests_tab.dart';
import '../widgets/my_friends_tab.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _friendService = FriendService();
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
          tabs: const [
            Tab(text: 'ค้นหา'),
            Tab(text: 'คำขอ'),
            Tab(text: 'ส่งคำขอ'),
            Tab(text: 'รายชื่อ'),
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
