import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme_provider.dart';

class ProfilePage extends StatelessWidget {
  // Placeholder for user data
  final String username = "Tejasva Bansal";
  final String userEmail = "tejasva.bansal@gmail.com";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: ListView(
        children: [
          Container(
            color: Colors.deepPurple,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage("https://via.placeholder.com/150"),
                    backgroundColor: Colors.grey.shade800,
                  ),
                  SizedBox(height: 10),
                  Text(
                    username,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.deepPurple),
            title: Text('Settings'),
            onTap: () {
              // Navigate to settings page or open settings modal
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: Colors.red),
            title: Text('Log Out'),
            onTap: () {
              // Handle account access, such as logging out
            },
          ),
          ListTile(
  leading: Icon(Icons.brightness_4),
  title: Text('Toggle Dark/Light Theme'),
  onTap: () {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.themeData = themeProvider.themeData.brightness == Brightness.dark
        ? ThemeData.light()
        : ThemeData.dark();
  },
),
        ],
      ),
    );
  }
}
