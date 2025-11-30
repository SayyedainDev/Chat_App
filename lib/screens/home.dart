import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:phone_app/screens/Users_list.dart';
import 'package:phone_app/screens/messages.dart';
import 'package:phone_app/screens/user_profile.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  // 📦 Store pages in a list
  final List<Widget> _pages = [
    UsersListScreen(),
    ChattedUsersScreen(),
    UserProfile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        color: Colors.orange,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: GNav(
            onTabChange: _onItemTapped,
            gap: 8,
            backgroundColor: Colors.orange, // Make the whole bar orange
            activeColor: Colors.white, // Active icon/text is white
            tabBackgroundColor: Colors.orange
                .shade700, // Slightly darker orange for selected tab background (optional, can be same as background)
            color: Colors.white70,
            padding: EdgeInsets.all(
                16), // Inactive icon/text is slightly transparent white
            tabs: const [
              GButton(
                icon: Icons.group,
                text: 'All Users',
              ),
              GButton(icon: Icons.message, text: 'Messages'),
              GButton(icon: Icons.person, text: 'Profile')
            ],
          ),
        ),
      ), // 👈 display selected page
    );
  }
}
