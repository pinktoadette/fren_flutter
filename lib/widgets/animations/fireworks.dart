import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Fireworks extends StatelessWidget {
  double? height;
  double? width;

  Fireworks({Key? key, this.height, this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'assets/lottie/fireworks.json',
        width: height ?? 200,
        height: width ?? 200,
      ),
    );
  }
}
