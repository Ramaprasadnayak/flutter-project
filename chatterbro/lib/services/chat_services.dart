import 'package:chatterbro/models/mesage.dart';  
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> deleteChatRoom(String otherUserId) async {
  final currentUser = _auth.currentUser;
  if (currentUser == null) throw Exception("Not logged in");

  List<String> ids = [currentUser.uid, otherUserId];
  ids.sort();
  String chatRoomID = ids.join('_');

  final chatRef = _firestore.collection('chat_rooms').doc(chatRoomID);

  // Delete all messages in the chat room first
  final messagesSnapshot = await chatRef.collection('messages').get();
  final batch = _firestore.batch();
  for (var doc in messagesSnapshot.docs) {
    batch.delete(doc.reference);
  }
  await batch.commit();

  // Delete chat room itself
  await chatRef.delete();
}


  Stream<List<Map<String, dynamic>>> getUsersStream() {
    final currentUid = _auth.currentUser!.uid;
    final currentEmail = _auth.currentUser!.email!;  // For filtering self

    return _firestore
        .collection('chat_rooms')
        .where('users', arrayContains: currentUid)  // Only chats this user is in
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            final users = List<String>.from(data['users'] ?? []);
            final emails = List<String>.from(data['emails'] ?? []);
            final otherUid = users.firstWhere(
              (uid) => uid != currentUid,
              orElse: () => '',
            );

            // Find matching email (assumes 'emails' order matches 'users')
            final otherEmailIndex = users.indexOf(otherUid);
            final otherEmail = otherEmailIndex != -1 ? emails[otherEmailIndex] : '';

            // Skip if invalid or self (edge case)
            if (otherUid.isEmpty || otherEmail == currentEmail) {
              return <String, dynamic>{};  // Empty map to filter out
            }

            return {
              'email': otherEmail,
              'uid': otherUid,
              // Optional: Add 'lastMessage': data['lastMessage'] for UI previews
            };
          }).where((userData) => userData.isNotEmpty).toList();  // Filter invalid
        });
  }



  Future<void> sendMessage(String receiverId, String message) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("Not logged in");
    }
    if (message.trim().isEmpty) {
      throw Exception("Message cannot be empty");
    }

    final currentUid = currentUser.uid;
    final currentEmail = currentUser.email!;
    final timestamp = FieldValue.serverTimestamp();

    // Build chatRoomID (sorted for uniqueness)
    List<String> ids = [currentUid, receiverId];
    ids.sort();
    final chatRoomID = ids.join('_');
    final chatRef = _firestore.collection('chat_rooms').doc(chatRoomID);
    final messagesRef = chatRef.collection('messages');
    await _firestore.runTransaction((transaction) async {
      final chatSnapshot = await transaction.get(chatRef);

      if (!chatSnapshot.exists) {
        // Lazy create: Fetch receiver's email (targeted read - allowed by rules)
        final receiverSnapshot = await _firestore.collection('Users').doc(receiverId).get();
        final receiverEmail = receiverSnapshot.exists
            ? (receiverSnapshot.data()!['email'] as String? ?? receiverId)  // Use email or fallback to UID
            : receiverId;  // Fallback if user doc missing

        // Set parent with required structure (satisfies rules: 'users' list of 2, 'emails' present)
        transaction.set(chatRef, {
          'users': ids,  // Exactly 2 UIDs (list of strings)
          'emails': [currentEmail, receiverEmail],  // Fixed: Actual email, not UID
          'lastMessage': message.trim(),
          'updatedAt': timestamp,
        });
      } else {
        // Existing chat: Update metadata only
        transaction.update(chatRef, {
          'lastMessage': message.trim(),
          'updatedAt': timestamp,
        });
      }

      // Add message (parent now guaranteed to exist with 'users')
      final newMessage = Message(
        senderId: currentUid,
        senderEmail: currentEmail,
        receiverId: receiverId,  // Keep if your model needs it
        message: message.trim(),
        timestamp: timestamp,
      );
      transaction.set(messagesRef.doc(), newMessage.toMap());  // Auto-ID, atomic with above
    });
  }

  // Add new chat by email (updated: normalization, no throw on existing, self-check, rules compliance)
  Future<void> addChatByEmail(String targetEmail) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("No user logged in");
    }

    // Normalize target email (lowercase, trim) for consistency
    final normalizedTargetEmail = targetEmail.toLowerCase().trim();

    // Check if target email exists in Firebase Auth
    final methods = await _auth.fetchSignInMethodsForEmail(normalizedTargetEmail);
    if (methods.isEmpty) {
      throw Exception("No user found with that email (not registered in the app)");
    }

    //  Get target user's UID from Firestore (query normalized)
    final userQuery = await _firestore
        .collection('Users')
        .where('email', isEqualTo: normalizedTargetEmail)
        .get();

    if (userQuery.docs.isEmpty) {
      throw Exception("User not found in database (possible sync issue)");
    }

    final targetUid = userQuery.docs.first.id;
    final targetEmailFromDb = userQuery.docs.first.data()['email'] as String;  // Normalized from DB

    // Skip if self-chat
    if (targetUid == currentUser.uid) {
      throw Exception("Cannot create chat with yourself");
    }

    //  Build unique chatRoomID (sorted)
    List<String> ids = [currentUser.uid, targetUid];
    ids.sort();
    String chatRoomID = ids.join('_');

    //  Check if chat already exists (no throw: just update metadata for UX)
    final chatDoc = await _firestore.collection('chat_rooms').doc(chatRoomID).get();
    if (chatDoc.exists) {
      await _firestore.collection('chat_rooms').doc(chatRoomID).update({
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return;  // Success: Already in list
    }

    // Create new chat room metadata (ensures rules pass: exactly 2 users, required fields)
    await _firestore.collection('chat_rooms').doc(chatRoomID).set({
      'users': [currentUser.uid, targetUid],  // Array of exactly 2
      'emails': [currentUser.email!, targetEmailFromDb],  // Normalized
      'lastMessage': '',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(String userId, String otherUserId) {
  List<String> ids = [userId, otherUserId];
  ids.sort();
  String chatRoomID = ids.join('_');
  final chatRef = FirebaseFirestore.instance.collection('chat_rooms').doc(chatRoomID);

  return chatRef.snapshots().asyncExpand((chatSnap) {
    if (!chatSnap.exists || chatSnap.data()?['users'] == null) {
      // Chat doesn't exist: return an empty stream
      return FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc('dummy') // dummy doc
          .collection('messages')
          .limit(0)
          .snapshots();
    }

    // Chat exists: return real messages stream
    return chatRef
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  });
}
  Future<void> clearChat(String userId, String otherUserId) async {
  List<String> ids = [userId, otherUserId];
  ids.sort();
  String chatRoomID = ids.join('_');

  final chatRef = FirebaseFirestore.instance
      .collection('chat_rooms')
      .doc(chatRoomID)
      .collection('messages');

  final snapshot = await chatRef.get();

  // Batch delete all messages
  final batch = FirebaseFirestore.instance.batch();
  for (var doc in snapshot.docs) {
    batch.delete(doc.reference);
  }
  await batch.commit();

  // Optional: clear lastMessage & updatedAt in chat room
  await FirebaseFirestore.instance
      .collection('chat_rooms')
      .doc(chatRoomID)
      .update({
    'lastMessage': '',
    'updatedAt': FieldValue.serverTimestamp(),
  });
}


}