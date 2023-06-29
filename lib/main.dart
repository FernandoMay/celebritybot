import 'package:celebritybot/celebrities.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Celebrity Chatbot',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const CelebrityScreen(),
    );
  }
}
