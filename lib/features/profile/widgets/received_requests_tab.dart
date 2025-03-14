import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/text_styles.dart';
import '../services/friend_service.dart';

class ReceivedRequestsTab extends StatelessWidget {
  final String currentUserId;
  final FriendService friendService;

  const ReceivedRequestsTab({
    super.key,
    required this.currentUserId,
    required this.friendService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: friendService.getReceivedFriendRequests(currentUserId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data!.docs;
        if (requests.isEmpty) {
          return Center(
            child: Text(
              'ไม่มีคำขอเป็นเพื่อน',
              style: AppTextStyles.body,
            ),
          );
        }

        return BootstrapContainer(
          fluid: true,
          padding: const EdgeInsets.all(16.0),
          children: [
            BootstrapRow(
              children: [
                BootstrapCol(
                  sizes: 'col-xs-12 col-sm-12 col-md-10 col-lg-8',
                  offsets: "offset-md-1 offset-lg-2",
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: requests.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final doc = requests[index];
                      final requestId = doc.id;
                      final senderId = doc['sender_id'] as String;
                      final receiverId = doc['receiver_id'] as String;

                      return FutureBuilder<DocumentSnapshot>(
                        future: friendService.getUserData(senderId),
                        builder: (context, senderSnapshot) {
                          if (!senderSnapshot.hasData) {
                            return ListTile(
                              title: Text(
                                'กำลังโหลด...',
                                style: AppTextStyles.body,
                              ),
                            );
                          }

                          final senderData = senderSnapshot.data?.data()
                              as Map<String, dynamic>?;
                          if (senderData == null) {
                            return ListTile(
                              title: Text(
                                'ไม่พบข้อมูลผู้ใช้',
                                style: AppTextStyles.body,
                              ),
                            );
                          }

                          final senderName =
                              senderData['username'] ?? 'No Name';
                          final senderProfile =
                              senderData['profileImageUrl'] ?? '';

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: senderProfile.isNotEmpty
                                  ? NetworkImage(senderProfile)
                                  : null,
                              child: senderProfile.isEmpty
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(
                              senderName,
                              style: AppTextStyles.subtitle,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  onPressed: () =>
                                      friendService.acceptFriendRequest(
                                    requestId,
                                    senderId,
                                    receiverId,
                                  ),
                                  child: const Text(
                                    'ยืนยัน',
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => friendService
                                      .declineFriendRequest(requestId),
                                  child: const Text(
                                    'ปฏิเสธ',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
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
        );
      },
    );
  }
}
