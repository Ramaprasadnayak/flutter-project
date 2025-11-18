import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthServices {
  //create instances of firebase auth and firestore so that u dont hav to caall explicitily
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //boolean to check current user
  User? getCurrentuser() {
    return _auth.currentUser;
  }

  // Sign In
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Update user info in Firestore
      await _firestore.collection("Users").doc(userCredential.user!.uid).set(
        {
          'uid': userCredential.user!.uid,
          'email': email,
          'lastLogin': DateTime.now(),
        },
        SetOptions(merge: true),
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // Sign Up
  Future<UserCredential> signUpWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection("Users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'createdAt': DateTime.now(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }
Future<void> addChatByEmail(BuildContext context,String username, String targetEmail) async {
  final currentUser = _auth.currentUser;
  if (currentUser == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("You must be logged in to start a chat.")),
    );
    return;
  }

  if (targetEmail.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please enter an email.")),
    );
    return;
  }

  try {
    // Check if target email exists in Firestore
    final userQuery = await _firestore
        .collection('Users')
        .where('email', isEqualTo: targetEmail.trim())
        .get();

    if (userQuery.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No user found with email: $targetEmail")),
      );
      return;
    }

    final targetUid = userQuery.docs.first.id;

    // Prevent self-chat
    if (targetUid == currentUser.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You cannot start a chat with yourself.")),
      );
      return;
    }

    // Create a unique chatId (sorted)
    final chatId = currentUser.uid.compareTo(targetUid) > 0
        ? '${currentUser.uid}_$targetUid'
        : '${targetUid}_${currentUser.uid}';

    // Create or merge chat document
    await _firestore.collection('chat_rooms').doc(chatId).set({
      'users': [currentUser.uid, targetUid],
      'emails': [currentUser.email, targetEmail],
      'lastMessage': '',
      'updatedAt': DateTime.now(),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Chat created successfully...")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: ${e.toString()}")),
    );
  }
}

}
