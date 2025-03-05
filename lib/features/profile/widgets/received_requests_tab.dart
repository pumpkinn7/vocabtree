import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/text_styles.dart';
import '../services/friend_service.dart';

class ReceivedRequestsTab extends StatelessWidget {
  final String currentUserId;
  final FriendService friendService;

  const ReceivedRequestsTab({
    super.key, // แก้ไขเป็น super parameter
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
              'ไม่มีคำขอที่ได้รับ',
              // แก้ไขการใช้ AppTextStyles
              style: AppTextStyles.body,
            ),
          );
        }

        return BootstrapContainer(
          fluid: true,
          decoration: const BoxDecoration(color: Colors.white),
          padding: const EdgeInsets.all(16.0),
          children: [
            BootstrapRow(
              children: [
                BootstrapCol(
                  sizes: 'col-12',
                  child: Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: requests.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final doc = requests[index];
                        final data = doc.data() as Map<String, dynamic>?;
                        if (data == null) {
                          return ListTile(
                            title: Text(
                              'ไม่พบข้อมูลคำขอ',
                              // แก้ไขการใช้ AppTextStyles
                              style: AppTextStyles.body,
                            ),
                          );
                        }

                        final requestId = doc.id;
                        final senderId = data['sender_id'];
                        final receiverId = data['receiver_id'];

                        return FutureBuilder<DocumentSnapshot>(
                          future: friendService.getUserData(senderId),
                          builder: (context, userSnapshot) {
                            if (!userSnapshot.hasData) {
                              return ListTile(
                                title: Text(
                                  'กำลังโหลด...',
                                  // แก้ไขการใช้ AppTextStyles
                                  style: AppTextStyles.body,
                                ),
                              );
                            }

                            final userData = userSnapshot.data?.data()
                                as Map<String, dynamic>?;
                            if (userData == null) {
                              return ListTile(
                                title: Text(
                                  'ไม่พบข้อมูลผู้ส่ง',
                                  // แก้ไขการใช้ AppTextStyles
                                  style: AppTextStyles.body,
                                ),
                              );
                            }

                            final senderName =
                                userData['username'] ?? 'No Name';
                            final senderProfile =
                                userData['profileImageUrl'] ?? '';

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
                                // แก้ไขการใช้ AppTextStyles
                                style: AppTextStyles.subtitle,
                              ),
                              subtitle: Text(
                                'ส่งคำขอเป็นเพื่อนถึงคุณ',
                                // แก้ไขการใช้ AppTextStyles
                                style: AppTextStyles.caption,
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
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
