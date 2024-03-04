import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
