import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'splash_screen.dart'; // Import the splash screen
import 'fav_screen.dart';  // Ensure these imports are correct
import 'home_screen.dart'; // Ensure this import is correct
import 'search_screen.dart';
import 'chat_bot_screen.dart';
import 'tour_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prakriti App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue,
          secondary: Colors.blueAccent,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blueGrey[900],
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.blueGrey[800],
          selectedItemColor: Color(0xFFF39C12),
          unselectedItemColor: Colors.grey,
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        scaffoldBackgroundColor: Colors.blueGrey[900],
      ),
      home: SplashScreen(), // Set SplashScreen as the initial route
    );
  }
}
