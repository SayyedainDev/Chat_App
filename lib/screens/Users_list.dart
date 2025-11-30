import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phone_app/screens/chatScreen.dart';
import 'package:phone_app/screens/messages.dart';
import 'package:phone_app/screens/user_profile.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  Stream<List<Map<String, dynamic>>> fetchAllUsersExceptCurrent() {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    // Ensure currentUid is not null before querying
    if (currentUid == null) {
      // If no user is logged in, return an empty stream or handle appropriately
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection('users')
        .where('uid', isNotEqualTo: currentUid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      appBar: AppBar(
        title: const Text(
          "All Users",
        ),
        backgroundColor:
            Colors.orange, // Added app bar background color for consistency
      ),

      // L
      //ight peach background
      body: SafeArea(
        // Use SafeArea to avoid notches/status bar
        child: Column(
          // Use Column directly to fill the screen
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Removed the extra SizedBox(height: 32.0) here as Card's padding will manage spacing
            // User List StreamBuilder - Expanded to take remaining space
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: fetchAllUsersExceptCurrent(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFFF8C00)), // Orange color
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "No users found.",
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    );
                  }

                  final users = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0), // Adjusted padding for the list
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final userName = user['name'] ?? 'No Name';
                      final userInitial =
                          userName.isNotEmpty ? userName[0].toUpperCase() : '';

                      return Padding(
                        padding: const EdgeInsets.only(
                            bottom: 12.0), // Spacing between items
                        child: Card(
                          // Replaced Material with Card for better shadow and shape control
                          elevation:
                              4, // Increased elevation for a more prominent shadow
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                15), // Slightly more rounded corners
                          ),
                          child: InkWell(
                            onTap: () {
                              print("User id :${user['uid']}");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    chattedUserName: userName,
                                    Uid: user['uid'],
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(
                                15), // Match Card's border radius
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical:
                                      12.0), // Increased padding inside the card
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 25, // Increased avatar size
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
                                    child: Text(
                                      userName,
                                      style: const TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1F2937),
                                      ),
                                      overflow: TextOverflow.ellipsis,
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
            ),
          ],
        ),
      ),
    );
  }
}
