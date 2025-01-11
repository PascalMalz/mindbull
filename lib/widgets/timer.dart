import 'package:flutter/material.dart';


class ButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onClicked;

  const ButtonWidget({
    super.key,
    required this.text,
    required this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
    onPressed: onClicked,
      child: Text(
        text,
        style: const TextStyle(fontSize: 20),
      )
    );
  }
}


