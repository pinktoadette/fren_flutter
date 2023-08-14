import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  // Variable
  final double? width;
  final double? height;
  final bool? useTheme;

  const AppLogo({Key? key, this.width, this.height, this.useTheme = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = true;
    if (useTheme == true) {
      isDarkMode = Theme.of(context).brightness == Brightness.dark;
    }

    return Center(
        child: Image.asset(
            isDarkMode
                ? "assets/images/logo_white.png"
                : "assets/images/machi.png",
            width: width ?? 120,
            height: height ?? 40));
  }
}
