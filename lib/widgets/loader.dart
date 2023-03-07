import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Frankloader extends StatelessWidget {

  const Frankloader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset('assets/lottie/loader.json',
        width: 200,
        height: 200,
      ),
    );
  }
}
