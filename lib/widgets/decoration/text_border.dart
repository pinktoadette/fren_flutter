import 'package:flutter/material.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/theme_helper.dart';

class TextBorder extends StatelessWidget {
  final String text;
  final double? size;
  final TextAlign? textAlign;
  final int? maxLines;

  const TextBorder(
      {Key? key, required this.text, this.size, this.textAlign, this.maxLines})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = ThemeHelper().loadThemeFromBox();
    if (isDarkMode == false) {
      return Text(text,
          textAlign: textAlign ?? TextAlign.left,
          maxLines: maxLines,
          style: Theme.of(context).textTheme.bodyMedium);
    }

    return Text(
      text,
      textAlign: textAlign ?? TextAlign.left,
      maxLines: maxLines,
      style: TextStyle(
          inherit: true,
          color: APP_INVERSE_PRIMARY_COLOR,
          fontSize: size ?? 16,
          shadows: const [
            Shadow(
                // bottomLeft
                offset: Offset(-1.0, -1.0),
                color: APP_PRIMARY_COLOR),
            Shadow(
                // bottomRight
                offset: Offset(1.0, -1.0),
                color: APP_PRIMARY_COLOR),
            Shadow(
                // topRight
                offset: Offset(1.0, 1.0),
                color: APP_PRIMARY_COLOR),
            Shadow(
                // topLeft
                offset: Offset(-1.0, 1.0),
                color: APP_PRIMARY_COLOR),
          ]),
    );
  }
}
