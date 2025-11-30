import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phone_app/screens/chatScreen.dart';

class ChattedUsersScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String getChatRoomId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return ids.join('_');
  }

  Future<List<Map<String, dynamic>>> fetchChattedUsers() async {
    final currentUserId = _auth.currentUser!.uid;
    final allUsersSnapshot = await _firestore.collection('users').get();
    List<Map<String, dynamic>> chattedUsers = [];

    for (final userDoc in allUsersSnapshot.docs) {
      final userData = userDoc.data();
      final otherUserId = userDoc.id;

      if (otherUserId == currentUserId) continue;

      final chatRoomId = getChatRoomId(currentUserId, otherUserId);

      print('Checking messages for chatRoomId: $chatRoomId');

      try {
        final messagesSnapshot = await _firestore
            .collection('chat_rooms')
            .doc(chatRoomId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        if (messagesSnapshot.docs.isNotEmpty) {
          final lastMessage = messagesSnapshot.docs.first.data();
          chattedUsers.add({
            'userId': otherUserId,
            'name': userData['name'],
            'email': userData['email'],
            'lastMessage': lastMessage['message'] ?? '',
            'timestamp': lastMessage['timestamp'],
          });
          print('Added ${userData['name']} to chatted users list');
        } else {
          print('No messages found with ${userData['name']}');
        }
      } catch (e) {
        print('Error fetching messages for $chatRoomId: $e');
      }
    }

    // Sort by latest message
    chattedUsers.sort((a, b) =>
        (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp));

    return chattedUsers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2), // Consistent background
      appBar: AppBar(
        title: const Text("Chatted Users"),
        backgroundColor: Colors.orange, // Consistent app bar color
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchChattedUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8C00)),
            ));
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text(
              "No chats yet",
              style: TextStyle(
                fontSize: 16.0,
                color: Color(0xFF4B5563),
              ),
            ));
          }

          final chattedUsers = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 8.0), // Padding for the list
            itemCount: chattedUsers.length,
            itemBuilder: (context, index) {
              final user = chattedUsers[index];
              final userName = user['name'] ?? 'No Name';
              final userInitial =
                  userName.isNotEmpty ? userName[0].toUpperCase() : '';
              final lastMessage = user['lastMessage'] as String;

              return Padding(
                padding: const EdgeInsets.only(
                    bottom: 12.0), // Spacing between items
                child: Card(
                  // Use Card for better visual appeal
                  elevation: 4, // Add a subtle shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Rounded corners
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            Uid: user['userId'],
                            chattedUserName: userName,
                          ),
                        ),
                      );
                    },
                    borderRadius:
                        BorderRadius.circular(15), // Match Card's border radius
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 12.0), // Internal padding
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 25, // Avatar size
                            backgroundColor: const Color(
                                0xFFFF8C00), // Orange avatar background
                            child: Text(
                              userInitial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1F2937),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(
                                    height:
                                        4), // Space between name and message
                                Text(
                                  lastMessage.length >
                                          40 // Adjusted length for subtitle
                                      ? '${lastMessage.substring(0, 40)}...'
                                      : lastMessage,
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios,
                              color: Colors.grey, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
