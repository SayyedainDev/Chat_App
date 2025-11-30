import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:phone_app/model/chat_model.dart";

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Get Users (if you’re listing chat rooms or users)
  // Stream<List<Map<String, dynamic>>> getUsersStream() {
  //   return _firestore.collection('chat_rooms').snapshots().map((snapshot) {
  //     return snapshot.docs.map((doc) {
  //       final user = doc.data();
  //       return user;
  //     }).toList();
  //   });
  // }

  // Send Message
  Future<void> sendMessage(String receiverid, message) async {
    try {
      final String currentUserid = _firebaseAuth.currentUser!.uid;
      final String currentuserEmail = _firebaseAuth.currentUser!.email!;
      final Timestamp timestamp = Timestamp.now();

      print("Preparing to send message...");
      print("Sender UID: $currentUserid, Receiver UID: $receiverid");

      Message newMessage = Message(
        senderId: currentUserid,
        senderEmail: currentuserEmail,
        receiverid: receiverid,
        message: message,
        timestamp: timestamp,
      );

      List<String> ids = [currentUserid, receiverid];
      ids.sort(); // ensures chat room id is consistent
      String chatRoomId = ids.join('_');

      print("ChatRoom ID: $chatRoomId");

      await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(newMessage.toMap());

      print("Message sent successfully to Firestore.");
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  // Get Messages
  Stream<QuerySnapshot> getMessages(String userId, otheruserId) {
    List<String> ids = [userId, otheruserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    print("Listening to messages for ChatRoom ID: $chatRoomId");

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
