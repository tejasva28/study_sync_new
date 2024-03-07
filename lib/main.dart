import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_sync/Models/time_scheduling_model.dart';
import 'package:study_sync/Pages/home.dart';
import 'package:study_sync/Pages/profile_page.dart';
import 'Pages/Home.dart';
import 'Pages/login_screen.dart';
import 'Pages/time_scheduling_page.dart';
import 'Pages/video_add.dart';
import 'Pages/video_page.dart';
import 'theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for async main
  runApp(const MyApp()); // Run the app
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> mockJson = {
      "playlistLink": "http://example.com",
      "playlistTitle": "Test Playlist",
      "thumbnailUrl": "http://example.com/thumbnail.jpg",
      "selectedDateTime": "2022-01-01T12:00:00Z",
      "videoCount": 5,
      "totalDuration": 3600, // Example in seconds
      "videos": [
        {
          "id": "video1",
          "title": "Video 1",
          "description": "The first video",
          "url": "http://example.com/video1",
          "thumbnailUrl": "http://example.com/video1/thumbnail.jpg",
          "duration": 600
        },
        // Add more video objects as needed
      ]
    };



     // Convert mock JSON to a PlaylistSchedule object
    PlaylistSchedule playlistSchedule = PlaylistSchedule.fromJson(mockJson);

    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(ThemeData.light()), // Initializes with a light theme
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: themeProvider.themeData, // Use the dynamic theme
            home: VideoAdd(),
            // Add other routes and configuration as needed
          );
        },
      ),
    );
  }
}
