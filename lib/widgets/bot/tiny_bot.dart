import 'package:flutter/material.dart';


class TinyBotIcon extends StatelessWidget {
  final String image;
  const TinyBotIcon({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Initialization

    return SizedBox(
      height: 20,
      child: Image.asset(image)
    );
  }
}