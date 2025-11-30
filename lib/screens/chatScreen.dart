import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Required for User type
import 'package:intl/intl.dart';
import 'package:phone_app/Statemangement/AuthProvider.dart';
import 'package:phone_app/services/chat_service.dart';
import 'package:provider/provider.dart'; // Import the provider package
import 'profile_screen.dart'; // Assuming profile_screen.dart exists and contains ProfileScreen
// Import your AuthProviderS class

class ChatScreen extends StatefulWidget {
  final String chattedUserName;
  final String Uid;
  // Removed currentUser and currentUserToken as they will be accessed via Provider

  const ChatScreen({
    super.key,
    required this.chattedUserName,
    required this.Uid,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final _auth = FirebaseAuth.instance;

  void SendMessage() async {
    if (_messageController.text.isNotEmpty) {
      print("Sending message: ${_messageController.text}");
      await _chatService.sendMessage(widget.Uid, _messageController.text);
      _messageController.clear();
    } else {
      print("Message is empty, not sending.");
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access the AuthProviderS instance
    final authProvider = Provider.of<AuthProviderS>(context);
    final currentUser =
        authProvider.user; // Get the current user from the provider

    // Handle case where current user is null (e.g., not logged in)
    if (currentUser == null) {
      // You might want to navigate back to login or show an error
      return Scaffold(
        backgroundColor: const Color(0xFFF8F5F2),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
              const SizedBox(height: 20),
              const Text(
                "User not logged in. Redirecting...",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              // Optionally add a button to go back to login if needed
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.popUntil(context, (route) => route.isFirst); // Example: go back to first route
              //   },
              //   child: const Text("Go to Login"),
              // ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 178, 12),
        elevation: 0,
        title: GestureDetector(
          onTap: () async {
            final currentUserToken = await currentUser.getIdToken();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(Uid: widget.Uid),
              ),
            );
          },
          child: Text(
            widget.chattedUserName,
            style: const TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: const Color(
          0xFFF8F5F2), // Light peach background, consistent with other screens
      body: SafeArea(
        // Ensures content is not obscured by notches or status bar
        child: Column(
          children: [
            // Main chat messages area (currently empty, ready for chat bubbles)
            Expanded(
              child: _buildMessageList(),
            ),
            _buildUserInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    String _senderId = _auth.currentUser!.uid;

    return StreamBuilder(
      stream: _chatService.getMessages(widget.Uid, _senderId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print("Error fetching messages: ${snapshot.error}");
          return const Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          print("Waiting for message data...");
          return const Center(child: CircularProgressIndicator());
        }
        print("Messages loaded: ${snapshot.data!.docs.length}");
        return ListView(
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  // DateTime timestamp = DateTime
  //     .now(); // Or from Firebase: (doc['createdAt'] as Timestamp).toDate();
  // String formatted =;
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    print("Rendering message: ${data['message']}");
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
      child: Align(
        alignment: data['senderId'] == _auth.currentUser!.uid
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: data['senderId'] == _auth.currentUser!.uid
                ? const Color.fromARGB(255, 0, 0, 0)
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                data['message'],
                style: TextStyle(
                    fontSize: 16,
                    color: data['senderId'] == _auth.currentUser!.uid
                        ? Colors.white
                        : Colors.black),
              ),
              Text(
                  DateFormat.jm()
                      .format((doc['timestamp'] as Timestamp).toDate()),
                  style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInput() {
    return Row(
      children: [
        Expanded(
            child: Form(
          child: TextFormField(
              controller: _messageController,
              obscureText: false,
              keyboardAppearance: Brightness.light),
        )),
        IconButton(
          onPressed: SendMessage,
          icon: Icon(Icons.send),
          color: Colors.orange,
        ),
      ],
    );
  }
}
