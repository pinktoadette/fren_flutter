import 'package:flutter/material.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/theme_helper.dart';

class Bubble extends CustomPainter {
  bool isRight;

  final double _radius = 15.0;
  final double _x = 10.0;
  Bubble(this.isRight);

  @override
  void paint(Canvas canvas, Size size) {
    ThemeMode themeMode = ThemeHelper().themeMode;
    bool isDarkMode = themeMode == ThemeMode.dark;
    Color rightBubble =
        isDarkMode == true ? APP_INVERSE_PRIMARY_COLOR : Colors.white;

    canvas.drawRRect(
        RRect.fromLTRBAndCorners(
          0,
          0,
          size.width,
          size.height - _x,
          bottomLeft:
              isRight ? Radius.circular(_radius) : const Radius.circular(0),
          bottomRight:
              isRight ? const Radius.circular(0) : Radius.circular(_radius),
          topRight: Radius.circular(_radius),
          topLeft: Radius.circular(_radius),
        ),
        Paint()
          ..color = isRight ? APP_ACCENT_COLOR : rightBubble
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
