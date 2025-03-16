import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/text_styles.dart';
import '../services/friend_service.dart';

class SentRequestsTab extends StatelessWidget {
  final String currentUserId;
  final FriendService friendService;

  const SentRequestsTab({
    super.key,
    required this.currentUserId,
    required this.friendService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: friendService.getSentFriendRequests(currentUserId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data!.docs;
        if (requests.isEmpty) {
          return Center(
            child: Text(
              'ไม่มีคำขอที่ส่งออก',
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
                  offsets: "offset-xs-0 offset-sm-0 offset-md-1 offset-lg-2",
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: requests.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final doc = requests[index];
                      final requestId = doc.id;
                      final receiverId = doc['receiver_id'] as String;

                      return FutureBuilder<DocumentSnapshot>(
                        future: friendService.getUserData(receiverId),
                        builder: (context, receiverSnapshot) {
                          if (!receiverSnapshot.hasData) {
                            return ListTile(
                              title: Text(
                                'กำลังโหลด...',
                                style: AppTextStyles.body,
                              ),
                            );
                          }

                          final receiverData = receiverSnapshot.data?.data()
                              as Map<String, dynamic>?;
                          if (receiverData == null) {
                            return ListTile(
                              title: Text(
                                'ไม่พบข้อมูลผู้ใช้',
                                style: AppTextStyles.body,
                              ),
                            );
                          }

                          final receiverName =
                              receiverData['username'] ?? 'No Name';
                          final receiverProfile =
                              receiverData['profileImageUrl'] ?? '';

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: receiverProfile.isNotEmpty
                                  ? NetworkImage(receiverProfile)
                                  : null,
                              child: receiverProfile.isEmpty
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(
                              receiverName,
                              style: AppTextStyles.subtitle,
                            ),
                            trailing: TextButton(
                              child: Text(
                                'ยกเลิก',
                                style: AppTextStyles.buttonText.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                              onPressed: () =>
                                  friendService.cancelFriendRequest(requestId),
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
