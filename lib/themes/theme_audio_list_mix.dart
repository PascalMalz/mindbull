//not in use
//todo create themes
// Filename: theme_widget.dart

import 'package:flutter/material.dart';

class Theme1 extends StatelessWidget {
  const Theme1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Theme(
        data: ThemeData(
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.greenAccent, width: 2.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.greenAccent, width: 1.5),
            ),
          ),
          primarySwatch: Colors.deepPurple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          primaryColor: Colors.deepPurple,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.deepPurple,
              backgroundColor: Colors.greenAccent, // Text color
            ),
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.blue),
            bodyMedium: TextStyle(color: Colors.red),
            // ... and so on for other text styles
          ),
        ),
        child: const Center(
          child: Text('Hello, Theme1!'),
        ),
      ),
    );
  }
}
