import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phone_app/Statemangement/AuthProvider.dart';
import 'package:provider/provider.dart'; // Import provider to access AuthProviderS
// Import your AuthProviderS class

class ProfileScreen extends StatefulWidget {
  // This screen is now solely for displaying the current user's profile.
  // No longer takes 'user' or 'token' as parameters, relies on Provider.
  String Uid;

  ProfileScreen({super.key, required this.Uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoadingUserData = true;
  String? _userDataError;

  User? _currentUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUserData();
    });
  }

  Future<void> _initializeUserData() async {
    final authProvider = Provider.of<AuthProviderS>(context, listen: false);
    _currentUser = authProvider.user;

    if (_currentUser != null) {
      _fetchUserData(); // Fetch Firestore data using the obtained user
    } else {
      setState(() {
        _isLoadingUserData = false;
        _userDataError = "No authenticated user found.";
      });
      // If no user is found, you might want to navigate back to the login screen.
      // For this simplified profile display, we'll just show a message.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("No user logged in. Please log in."),
      ));
    }
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoadingUserData = true;
      _userDataError = null;
    });
    try {
      if (_currentUser == null) {
        setState(() {
          _userDataError = "No user to fetch data for.";
          _isLoadingUserData = false;
        });
        return;
      }

      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.Uid)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          _userData = docSnapshot.data();
          _isLoadingUserData = false;
        });
      } else {
        setState(() {
          _userDataError = "User data not found in Firestore.";
          _isLoadingUserData = false;
        });
      }
    } catch (e) {
      setState(() {
        _userDataError = "Failed to load user data: ${e.toString()}";
        _isLoadingUserData = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error fetching user data: ${e.toString()}"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProviderS>(context);
    _currentUser =
        authProvider.user; // Keep _currentUser updated if provider notifies

    if (_currentUser == null) {
      // Show loading or redirect if user is not yet loaded or logged out
      return Scaffold(
        backgroundColor: const Color(0xFFF8F5F2),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8C00)),
              ),
              const SizedBox(height: 20),
              Text(
                authProvider.isLoading
                    ? "Loading user..."
                    : "No user logged in. Redirecting...",
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2), // Light peach background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              Container(
                margin: const EdgeInsets.only(bottom: 24.0),
                child: Material(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(99.0),
                  child: InkWell(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("No previous page")),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(99.0),
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.grey,
                        size: 24.0,
                      ),
                    ),
                  ),
                ),
              ),

              const Text(
                "User Profile", // Changed title to "User Profile"
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 24.0),

              _isLoadingUserData
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFFFF8C00)),
                      ),
                    )
                  : _userDataError != null
                      ? Center(
                          child: Text(
                            _userDataError!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display Name
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.person,
                                      color: Color(0xFF4B5563), size: 24),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "Name: ${_userData?['name'] ?? _currentUser!.displayName ?? "N/A"}",
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        color: Color(0xFF374151),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Display Email
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.email,
                                      color: Color(0xFF4B5563), size: 24),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "Email: ${_userData?['email'] ?? _currentUser!.email ?? "N/A"}",
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        color: Color(0xFF374151),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Display Location (if available in Firestore data)
                            if (_userData?['location'] != null &&
                                _userData!['location'].isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        color: Color(0xFF4B5563), size: 24),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Location: ${_userData!['location']}",
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          color: Color(0xFF374151),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Display Gender (if available in Firestore data)
                            if (_userData?['gender'] != null &&
                                _userData!['gender'].isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.transgender,
                                        color: Color(0xFF4B5563), size: 24),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Gender: ${_userData!['gender']}",
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          color: Color(0xFF374151),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
              // Removed Set Password Button
              // Removed Logout Button
            ],
          ),
        ),
      ),
    );
  }
}
