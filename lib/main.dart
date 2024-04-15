import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:study_sync/theme_provider.dart';
import 'package:study_sync/Provider/auth_provider.dart';
import 'package:study_sync/Models/router.dart'
    as router_config; // Assuming your GoRouter setup is in this file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const MyApp(), // Replace with your actual MyApp widget
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // AuthProvider is already provided, so only include other necessary providers
        ChangeNotifierProvider(create: (_) => ThemeProvider(ThemeData.light())),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'Study Sync',
            theme: themeProvider.themeData.copyWith(
              textTheme: Theme.of(context).textTheme,
            ),
            // Use the routerConfig if it's required for your app's routing setup
            routerConfig: router_config.router,
          );
        },
      ),
    );
  }
}
