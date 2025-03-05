import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/text_styles.dart';
import '../services/friend_service.dart';

class SentRequestsTab extends StatelessWidget {
  final String currentUserId;
  final FriendService friendService;

  const SentRequestsTab({
    super.key, // แก้ไขเป็น super parameter
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
                        final receiverId = data['receiver_id'];

                        return FutureBuilder<DocumentSnapshot>(
                          future: friendService.getUserData(receiverId),
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

                            final receiverData = userSnapshot.data?.data()
                                as Map<String, dynamic>?;
                            if (receiverData == null) {
                              return ListTile(
                                title: Text(
                                  'ไม่พบข้อมูลผู้รับ',
                                  // แก้ไขการใช้ AppTextStyles
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
                                // แก้ไขการใช้ AppTextStyles
                                style: AppTextStyles.subtitle,
                              ),
                              subtitle: Text(
                                'คำขอรอดำเนินการ',
                                // แก้ไขการใช้ AppTextStyles
                                style: AppTextStyles.caption,
                              ),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.cancel, color: Colors.red),
                                onPressed: () => friendService
                                    .cancelFriendRequest(requestId),
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
