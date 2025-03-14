import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import '../../../core/theme/text_styles.dart';
import '../services/friend_service.dart';

class MyFriendsTab extends StatelessWidget {
  final String currentUserId;
  final FriendService friendService;

  const MyFriendsTab({
    super.key,
    required this.currentUserId,
    required this.friendService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: friendService.getFriendsList(currentUserId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final doc = snapshot.data;
        if (doc == null || doc.data() == null) {
          return Center(
            child: Text(
              'ยังไม่มีเพื่อน',
              style: AppTextStyles.body,
            ),
          );
        }

        final data = doc.data() as Map<String, dynamic>;
        final friendIds = data['friends'] ?? [];

        if (friendIds.isEmpty) {
          return Center(
            child: Text(
              'ยังไม่มีเพื่อน',
              style: AppTextStyles.body,
            ),
          );
        }

        return SingleChildScrollView(
          child: BootstrapContainer(
            fluid: true,
            padding: const EdgeInsets.all(16.0),
            children: [
              BootstrapRow(
                children: [
                  BootstrapCol(
                    sizes: 'col-xs-12 col-sm-12 col-md-10 col-lg-8',
                    offsets: 'offset-md-1 offset-lg-2',
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: friendIds.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final friendId = friendIds[index];
                        return FutureBuilder<DocumentSnapshot>(
                          future: friendService.getUserData(friendId),
                          builder: (context, friendSnapshot) {
                            if (!friendSnapshot.hasData) {
                              return ListTile(
                                title: Text(
                                  'กำลังโหลด...',
                                  style: AppTextStyles.body,
                                ),
                              );
                            }

                            final friendData = friendSnapshot.data?.data()
                                as Map<String, dynamic>?;
                            if (friendData == null) {
                              return ListTile(
                                title: Text(
                                  'ไม่พบข้อมูลเพื่อน',
                                  style: AppTextStyles.body,
                                ),
                              );
                            }

                            final friendName =
                                friendData['username'] ?? 'No Name';
                            final friendProfile =
                                friendData['profileImageUrl'] ?? '';

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: friendProfile.isNotEmpty
                                    ? NetworkImage(friendProfile)
                                    : null,
                                child: friendProfile.isEmpty
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              title: Text(
                                friendName,
                                style: AppTextStyles.subtitle,
                              ),
                              trailing: TextButton(
                                child: Text(
                                  'ลบเพื่อน',
                                  style: AppTextStyles.buttonText.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                onPressed: () => friendService.removeFriend(
                                  currentUserId,
                                  friendId,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
