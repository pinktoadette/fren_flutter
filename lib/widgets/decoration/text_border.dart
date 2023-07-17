import 'package:flutter/material.dart';
import 'package:machi_app/constants/constants.dart';

class TextBorder extends StatelessWidget {
  final String text;
  final double? size;

  const TextBorder({Key? key, required this.text, this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          inherit: true,
          fontSize: size ?? 20,
          color: APP_INVERSE_PRIMARY_COLOR,
          shadows: [
            Shadow(
                // bottomLeft
                offset: Offset(-1.0, -1.0),
                color: APP_PRIMARY_COLOR),
            Shadow(
                // bottomRight
                offset: Offset(1.0, -1.0),
                color: APP_PRIMARY_COLOR),
            Shadow(
                // topRight
                offset: Offset(1.0, 1.0),
                color: APP_PRIMARY_COLOR),
            Shadow(
                // topLeft
                offset: Offset(-1.0, 1.0),
                color: APP_PRIMARY_COLOR),
          ]),
    );
  }
}
