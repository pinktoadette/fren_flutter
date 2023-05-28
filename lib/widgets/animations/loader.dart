import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Frankloader extends StatelessWidget {
  final double? height;
  final double? width;

  const Frankloader({Key? key, this.height, this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'assets/lottie/frankie.json',
        width: height ?? 500,
        height: width ?? 200,
      ),
    );
  }
}
