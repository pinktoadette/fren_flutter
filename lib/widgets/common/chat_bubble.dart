import 'package:flutter/material.dart';
import 'package:machi_app/constants/constants.dart';

class Bubble extends CustomPainter {
  bool isRight;
  final double _radius = 15.0;
  final double _x = 10.0;
  Bubble(this.isRight);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
        RRect.fromLTRBAndCorners(
          0,
          0,
          size.width,
          size.height - _x,
          bottomLeft: Radius.circular(_radius),
          bottomRight: Radius.circular(_radius),
          topRight: Radius.circular(_radius),
          topLeft: Radius.circular(_radius),
        ),
        Paint()
          ..color = isRight ? APP_ACCENT_COLOR : Colors.white
          ..style = PaintingStyle.fill);
    var path = Path();
    path.moveTo(isRight ? size.width - 20 : 20, size.height - 12);
    path.lineTo(isRight ? size.width - 30 : 30, size.height);
    path.lineTo(isRight ? size.width - 40 : 40, size.height - 10);
    canvas.clipPath(path);
    canvas.drawRRect(
        RRect.fromLTRBAndCorners(
          0,
          0.0,
          size.width,
          size.height,
        ),
        Paint()
          ..color = isRight ? APP_ACCENT_COLOR : Colors.white
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
