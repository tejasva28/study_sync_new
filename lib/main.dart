import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_sync/Models/time_scheduling_model.dart';
import 'package:study_sync/Pages/home.dart';
import 'package:study_sync/Pages/login_screen.dart';
import 'package:study_sync/Pages/time_scheduling_page.dart';
import 'package:study_sync/Pages/video_add.dart';
import 'package:study_sync/Pages/video_page.dart';
import 'package:study_sync/theme_provider.dart';
import 'package:study_sync/Provider/auth_provider.dart';
import 'package:study_sync/Models/router.dart' as router_config; // Assuming your GoRouter setup is in this file

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider(ThemeData.light())),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'Study Sync',
            theme: themeProvider.themeData.copyWith(
              textTheme: Theme.of(context).textTheme,
              
            ),
            // routeInformationParser: router_config.router.routeInformationParser,
            // routerDelegate: router_config.router.routerDelegate,
            routerConfig: router_config.router,
          );
        },
      ),
    );
  }
}
