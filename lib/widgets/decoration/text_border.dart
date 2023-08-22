import 'package:flutter/material.dart';
import 'package:machi_app/constants/constants.dart';

class TextBorder extends StatelessWidget {
  final String text;
  final double? size;
  final TextAlign? textAlign;
  final int? maxLines;
  final bool? useTheme;

  const TextBorder(
      {Key? key,
      required this.text,
      this.size,
      this.textAlign,
      this.maxLines,
      this.useTheme = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          text,
          textAlign: textAlign,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: size ?? 16,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..color = Colors.black,
          ),
        ),
        Text(
          text,
          textAlign: textAlign,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: size ?? 16,
            color: APP_INVERSE_PRIMARY_COLOR,
          ),
        ),
      ],
    );
  }
}
