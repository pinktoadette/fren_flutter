import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class FrankImage extends StatelessWidget {
  const FrankImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset('assets/images/frank.png',
        width: 30,
        height: 30,
      ),
    );
  }
}
