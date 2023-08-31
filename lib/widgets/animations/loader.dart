import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:machi_app/constants/constants.dart';

class Frankloader extends StatelessWidget {
  final double? height;
  final double? width;
  final String? text;

  const Frankloader({Key? key, this.height, this.width, this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
        Lottie.asset(
          'assets/lottie/pup.json',
          width: width ?? 200,
          height: height ?? 200,
        ),
        Text(
          text ?? "",
          style: const TextStyle(color: APP_ACCENT_COLOR, fontSize: 16),
        )
      ],
    ));
  }
}
