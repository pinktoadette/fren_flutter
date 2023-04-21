import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class DesktopAnimation extends StatelessWidget {
  final double? height;
  final double? width;

  const DesktopAnimation({Key? key, this.height, this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'assets/lottie/desktop.json',
        width: height ?? 200,
        height: width ?? 200,
      ),
    );
  }
}
