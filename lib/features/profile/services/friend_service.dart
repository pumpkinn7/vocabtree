import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/friend_model.dart';

class FriendService {
  final FirebaseFirestore _firestore;

  FriendService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<FriendModel>> searchUsers(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final snapshot = await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return FriendModel(
        userId: doc.id,
        name: data['username'] ?? '',
        email: data['email'] ?? '',
        profileImage: data['profileImageUrl'] ?? '',
      );
    }).toList();
  }

  Future<void> sendFriendRequest(String senderId, String receiverId) async {
    final checkSnapshot = await _firestore
        .collection('friend_requests')
        .where('sender_id', isEqualTo: senderId)
        .where('receiver_id', isEqualTo: receiverId)
        .where('status', isEqualTo: 'pending')
        .get();

    if (checkSnapshot.docs.isEmpty) {
      await _firestore.collection('friend_requests').add({
        'sender_id': senderId,
        'receiver_id': receiverId,
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> cancelFriendRequest(String requestId) async {
    await _firestore.collection('friend_requests').doc(requestId).delete();
  }

  Future<void> acceptFriendRequest(
      String requestId, String senderId, String receiverId) async {
    await _firestore
        .collection('friend_requests')
        .doc(requestId)
        .update({'status': 'accepted'});

    await _firestore.collection('friends').doc(senderId).set(
      {
        'friends': FieldValue.arrayUnion([receiverId]),
      },
      SetOptions(merge: true),
    );

    await _firestore.collection('friends').doc(receiverId).set(
      {
        'friends': FieldValue.arrayUnion([senderId]),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> declineFriendRequest(String requestId) async {
    await _firestore
        .collection('friend_requests')
        .doc(requestId)
        .update({'status': 'declined'});
  }

  Future<void> removeFriend(String userId, String friendId) async {
    await _firestore.collection('friends').doc(userId).update({
      'friends': FieldValue.arrayRemove([friendId]),
    });
    await _firestore.collection('friends').doc(friendId).update({
      'friends': FieldValue.arrayRemove([userId]),
    });
  }

  Stream<QuerySnapshot> getReceivedFriendRequests(String userId) {
    return _firestore
        .collection('friend_requests')
        .where('receiver_id', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  Stream<QuerySnapshot> getSentFriendRequests(String userId) {
    return _firestore
        .collection('friend_requests')
        .where('sender_id', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  Stream<DocumentSnapshot> getFriendsList(String userId) {
    return _firestore.collection('friends').doc(userId).snapshots();
  }

  Future<DocumentSnapshot> getUserData(String userId) {
    return _firestore.collection('users').doc(userId).get();
  }
}
