import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phone_app/screens/login.dart';
import 'package:provider/provider.dart';
import 'package:phone_app/Statemangement/AuthProvider.dart';

class UserProfile extends StatefulWidget {
  @override
  State<UserProfile> createState() => _UserProfile();
}

class _UserProfile extends State<UserProfile> {
  Future<Map<String, dynamic>> fetchData() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final docSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!docSnapshot.exists || docSnapshot.data() == null) {
      throw Exception('User data not found.');
    }

    return docSnapshot.data()!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Page"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found.'));
          } else {
            final data = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blueGrey,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  ProfileTile(
                      icon: Icons.person,
                      label: 'Name',
                      value: data['name'] ?? 'N/A'),
                  ProfileTile(
                      icon: Icons.email,
                      label: 'Email',
                      value: data['email'] ?? 'N/A'),
                  ProfileTile(
                      icon: Icons.male,
                      label: 'Gender',
                      value: data['gender'] ?? 'N/A'),
                  ProfileTile(
                      icon: Icons.location_on,
                      label: 'Location',
                      value: data['location'] ?? 'N/A'),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      final user =
                          Provider.of<AuthProviderS>(context, listen: false);
                      user.logout();

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      ); // Adjust route
                    },
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),
                    label: const Text('Logout',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      backgroundColor: const Color.fromARGB(255, 255, 173, 20),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
    );
  }
}
