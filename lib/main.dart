import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'base/app_theme.dart';
import 'auth/login_screen.dart';
import 'providers/user_provider.dart';
import 'providers/post_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  // Wait for Flutter engine to be ready
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const CampusConnectApp(),
    ),
  );
}

class CampusConnectApp extends StatelessWidget {
  const CampusConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Campus Connect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const LoginScreen(),
    );
  }
}
