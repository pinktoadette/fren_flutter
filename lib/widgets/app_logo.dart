import 'package:flutter/material.dart';
import 'package:fren_app/helpers/theme_helper.dart';

class AppLogo extends StatelessWidget {
  // Variable
  final double? width;
  final double? height;

  const AppLogo({Key? key, this.width, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = ThemeHelper().loadThemeFromBox();

    return Center(
        child: Image.asset(
            isDarkMode
                ? "assets/images/logo_pink.png"
                : "assets/images/logo.png",
            width: width ?? 120,
            height: height ?? 120));
  }
}
