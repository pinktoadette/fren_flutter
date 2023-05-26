import 'package:flutter/material.dart';

class FadingEffect extends CustomPainter {
  final Alignment beginDirection = Alignment.bottomCenter;
  final Alignment endDirectoin = Alignment.topCenter;
  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromPoints(
      const Offset(0, 0),
      Offset(size.width, size.height),
    );
    LinearGradient lg =
        LinearGradient(begin: beginDirection, end: endDirectoin, colors: [
      const Color.fromARGB(255, 255, 255, 255).withOpacity(0),
      const Color.fromARGB(255, 255, 255, 255),
      const Color.fromARGB(255, 255, 255, 255)
    ]);
    Paint paint = Paint()..shader = lg.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(FadingEffect oldDelegate) => false;
}
