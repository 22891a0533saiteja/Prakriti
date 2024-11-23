import 'package:flutter/material.dart';
import 'package:prakriti/home_screen.dart';
import 'main.dart';
import 'LoginScreen.dart';
import 'main_screen.dart';
import 'home_screen.dart';
import 'SignupScreen.dart';// Make sure this file exists

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Simulate a delay to show the splash screen for a few seconds
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainScreen()),//changed for signup
      );
    });

    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Center(
        child: Text(
          'Prakriti App',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}
