import 'package:dlsapp/screens/User_screens/signin.dart';
import 'package:dlsapp/screens/User_screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF6A1B9A),
          primary: Color(0xFF6A1B9A),
          secondary: Color(0xFFF3E5F5),
          surface: Color(0xFFFFFDE7),
        ),
        scaffoldBackgroundColor: Color(0xFFFFFDE7),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF6A1B9A),
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black54),
        ),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}

