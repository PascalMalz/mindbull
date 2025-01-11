import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final String text;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onClicked;

  const ButtonWidget({
    super.key,
    required this.text,
    this.color = Colors.white,
    this.backgroundColor = Colors.black,
    required this.onClicked,
  });

@override
Widget build(BuildContext context) => ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: backgroundColor,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)
    ),
    onPressed: onClicked,
    child : Text(
      text,
      style: TextStyle(fontSize: 20),
    ),
  );
}