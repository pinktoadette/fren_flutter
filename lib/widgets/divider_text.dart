import 'package:flutter/material.dart';

class TextDivider extends StatelessWidget {
  final String text;

  const TextDivider({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(
          child: Divider(
            color: Colors.grey,
            height: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(text, style: const TextStyle(color: Colors.grey)),
        ),
        const Expanded(
          child: Divider(
            color: Colors.grey,
            height: 1,
          ),
        ),
      ],
    );
  }
}
