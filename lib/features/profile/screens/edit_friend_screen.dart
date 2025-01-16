import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditFriendScreen extends StatefulWidget {
  const EditFriendScreen({super.key, required this.currentUserId});

  final String currentUserId;

  @override
  State<EditFriendScreen> createState() => _EditFriendScreenState();
}

class _EditFriendScreenState extends State<EditFriendScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String query = '';
  // กำหนดเป็น List<Map<String, dynamic>> ให้ตรงตามประเภท
  List<Map<String, dynamic>> searchResults = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> searchUsers(String searchQuery) async {
    if (searchQuery.isEmpty) {
      setState(() => searchResults = []);
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: searchQuery)
        .where('username', isLessThanOrEqualTo: '$searchQuery\uf8ff')
        .get();

    // แคสต์เป็น Map<String, dynamic> โดยไม่ทำซ้ำ (unnecessary cast) หรือใช้ ?? {}
    final results = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'userId': doc.id,
        'name': data['username'] ?? '',
        'email': data['email'] ?? '',
        'profileImage': data['profileImageUrl'] ?? '',
      };
    }).toList();

    setState(() => searchResults = results);
  }

  Future<void> sendFriendRequest(String receiverId) async {
    final checkSnapshot = await FirebaseFirestore.instance
        .collection('friend_requests')
        .where('sender_id', isEqualTo: widget.currentUserId)
        .where('receiver_id', isEqualTo: receiverId)
        .where('status', isEqualTo: 'pending')
        .get();

    if (checkSnapshot.docs.isEmpty) {
      await FirebaseFirestore.instance.collection('friend_requests').add({
        'sender_id': widget.currentUserId,
        'receiver_id': receiverId,
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> cancelFriendRequest(String requestId) async {
    await FirebaseFirestore.instance
        .collection('friend_requests')
        .doc(requestId)
        .delete();
  }

  Future<void> acceptFriendRequest(
      String requestId,
      String senderId,
      String receiverId,
      ) async {
    await FirebaseFirestore.instance
        .collection('friend_requests')
        .doc(requestId)
        .update({'status': 'accepted'});

    await FirebaseFirestore.instance.collection('friends').doc(senderId).set(
      {
        'friends': FieldValue.arrayUnion([receiverId]),
      },
      SetOptions(merge: true),
    );

    await FirebaseFirestore.instance.collection('friends').doc(receiverId).set(
      {
        'friends': FieldValue.arrayUnion([senderId]),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> declineFriendRequest(String requestId) async {
    await FirebaseFirestore.instance
        .collection('friend_requests')
        .doc(requestId)
        .update({'status': 'declined'});
  }

  Future<void> removeFriend(String friendId) async {
    await FirebaseFirestore.instance
        .collection('friends')
        .doc(widget.currentUserId)
        .update({
      'friends': FieldValue.arrayRemove([friendId]),
    });
    await FirebaseFirestore.instance.collection('friends').doc(friendId).update({
      'friends': FieldValue.arrayRemove([widget.currentUserId]),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('จัดการเพื่อน'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'ค้นหา'),
            Tab(text: 'คำขอ'),
            Tab(text: 'ส่งคำขอ'),
            Tab(text: 'เพื่อนทั้งหมด'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildSearchTab(),
          buildReceivedRequestsTab(),
          buildSentRequestsTab(),
          buildMyFriendsTab(),
        ],
      ),
    );
  }

  Widget buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'ค้นหาเพื่อน',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() => query = value);
              searchUsers(value);
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              final user = searchResults[index];
              final userId = user['userId'];
              final profileImage = user['profileImage'] ?? '';

              // ตรวจสอบ userId ไม่ใช่ currentUserId
              final isCurrentUser = userId == widget.currentUserId;

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: profileImage.isNotEmpty
                      ? NetworkImage(profileImage)
                      : null,
                  child: profileImage.isEmpty ? const Icon(Icons.person) : null,
                ),
                title: Text(user['name'] ?? ''),
                subtitle: Text(user['email'] ?? ''),
                trailing: isCurrentUser
                    ? const Text(
                  'คุณ',
                  style: TextStyle(color: Colors.grey),
                )
                    : ElevatedButton(
                  onPressed: () async {
                    await sendFriendRequest(userId);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ส่งคำขอแล้ว')),
                    );
                  },
                  child: const Text('ส่งคำขอ'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }


  Widget buildReceivedRequestsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('friend_requests')
          .where('receiver_id', isEqualTo: widget.currentUserId)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final requests = snapshot.data!.docs;
        if (requests.isEmpty) {
          return const Center(child: Text('ไม่มีคำขอที่ได้รับ'));
        }
        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final doc = requests[index];
            final data = doc.data() as Map<String, dynamic>?;
            if (data == null) {
              return const ListTile(title: Text('ไม่พบข้อมูลคำขอ'));
            }
            final requestId = doc.id;
            final senderId = data['sender_id'];
            final receiverId = data['receiver_id'];
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(senderId)
                  .get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const ListTile(title: Text('กำลังโหลด...'));
                }
                final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
                if (userData == null) {
                  return const ListTile(title: Text('ไม่พบข้อมูลผู้ส่ง'));
                }
                final senderName = userData['username'] ?? 'No Name';
                final senderProfile = userData['profileImageUrl'] ?? '';
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: senderProfile.isNotEmpty
                        ? NetworkImage(senderProfile)
                        : null,
                    child: senderProfile.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(senderName),
                  subtitle: const Text('ส่งคำขอเป็นเพื่อนถึงคุณ'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () => acceptFriendRequest(
                          requestId,
                          senderId,
                          receiverId,
                        ),
                        child: const Text('ยืนยัน'),
                      ),
                      TextButton(
                        onPressed: () => declineFriendRequest(requestId),
                        child: const Text('ปฏิเสธ'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget buildSentRequestsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('friend_requests')
          .where('sender_id', isEqualTo: widget.currentUserId)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final requests = snapshot.data!.docs;
        if (requests.isEmpty) {
          return const Center(child: Text('ไม่มีคำขอที่ส่งออก'));
        }
        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final doc = requests[index];
            final data = doc.data() as Map<String, dynamic>?;
            if (data == null) {
              return const ListTile(title: Text('ไม่พบข้อมูลคำขอ'));
            }
            final requestId = doc.id;
            final receiverId = data['receiver_id'];
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(receiverId)
                  .get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const ListTile(title: Text('กำลังโหลด...'));
                }
                final receiverData =
                userSnapshot.data?.data() as Map<String, dynamic>?;
                if (receiverData == null) {
                  return const ListTile(title: Text('ไม่พบข้อมูลผู้รับ'));
                }
                final receiverName = receiverData['username'] ?? 'No Name';
                final receiverProfile = receiverData['profileImageUrl'] ?? '';
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: receiverProfile.isNotEmpty
                        ? NetworkImage(receiverProfile)
                        : null,
                    child: receiverProfile.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(receiverName),
                  subtitle: const Text('คำขอรอดำเนินการ'),
                  trailing: IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: () => cancelFriendRequest(requestId),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget buildMyFriendsTab() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('friends')
          .doc(widget.currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final doc = snapshot.data;
        if (doc == null || doc.data() == null) {
          return const Center(child: Text('ยังไม่มีเพื่อน'));
        }
        final data = doc.data() as Map<String, dynamic>;
        final friendIds = data['friends'] ?? [];
        if (friendIds.isEmpty) {
          return const Center(child: Text('ยังไม่มีเพื่อน'));
        }
        return ListView.builder(
          itemCount: friendIds.length,
          itemBuilder: (context, index) {
            final friendId = friendIds[index];
            return FutureBuilder<DocumentSnapshot>(
              future:
              FirebaseFirestore.instance.collection('users').doc(friendId).get(),
              builder: (context, friendSnapshot) {
                if (!friendSnapshot.hasData) {
                  return const ListTile(title: Text('กำลังโหลด...'));
                }
                final friendData =
                friendSnapshot.data?.data() as Map<String, dynamic>?;
                if (friendData == null) {
                  return const ListTile(title: Text('ไม่พบข้อมูลเพื่อน'));
                }
                final friendName = friendData['username'] ?? 'No Name';
                final friendProfile = friendData['profileImageUrl'] ?? '';
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: friendProfile.isNotEmpty
                        ? NetworkImage(friendProfile)
                        : null,
                    child:
                    friendProfile.isEmpty ? const Icon(Icons.person) : null,
                  ),
                  title: Text(friendName),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle),
                    onPressed: () => removeFriend(friendId),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
