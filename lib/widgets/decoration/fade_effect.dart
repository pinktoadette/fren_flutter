import 'package:flutter/material.dart';

class FadingEffect extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromPoints(
      const Offset(0, 0),
      Offset(size.width, size.height),
    );
    LinearGradient lg = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          //create 2 white colors, one transparent
          Color.fromARGB(0, 255, 255, 255).withOpacity(0.4),
          Color.fromARGB(255, 255, 255, 255)
        ]);
    Paint paint = Paint()..shader = lg.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(FadingEffect linePainter) => false;
}
