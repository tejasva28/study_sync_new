import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:study_sync/Provider/auth_provider.dart';
import '../pages/home.dart';
import '../pages/login_screen.dart';
import '../pages/video_add.dart';
import '../pages/time_scheduling_page.dart';
import '../pages/video_page.dart';
import '../Models/time_scheduling_model.dart';
import '../Models/video_model.dart';

final GoRouter router = GoRouter(
  routes: [

    GoRoute(
      path: '/',
      redirect: (_, __) => AuthProvider().isAuthenticated ? '/home' : '/login',
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => MonthDateRow(),
    ),
    GoRoute(
      path: '/VideoAdd',
      builder: (context, state) => VideoAdd(),
    ),
    GoRoute(
      path: '/timescheduling',
      builder: (context, state) {
        final playlistSchedule = state.extra as PlaylistSchedule?;
        if (playlistSchedule == null) {
          // Return an error page if the playlistSchedule is null
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Playlist schedule data is missing')),
          );
        }
        // Return the page with the data if it's not null
        return TimeSchedulingPage(playlistSchedule: playlistSchedule);
      },
    ),
    GoRoute(
      path: '/video',
      builder: (context, state) {
        final video = state.extra as VideoModel?;
        if (video == null) {
          // Return an error page if the video data is null
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('No video data provided')),
          );
        }
        // Return the page with the data if it's not null
        return VideoDetailsPage(video: video);
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Error')),
    body: Center(child: Text(state.error.toString())),
  ),
);

class Application extends StatelessWidget {
  const Application({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      title: 'Study Sync',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
  }

void main() {
  runApp(const Application());
}