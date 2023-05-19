import 'package:flutter/material.dart';
import 'package:machi_app/widgets/animations/loader.dart';
import 'package:iconsax/iconsax.dart';

class NoData extends StatelessWidget {
  // Variables
  final String? svgName;
  final Widget? icon;
  final String text;

  const NoData({Key? key, this.svgName, this.icon, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Handle icon
    late Widget _icon;
    // Check svgName
    if (svgName != null) {
      // Get SVG icon
      _icon = const Icon(Iconsax.briefcase);
    } else {
      _icon = Frankloader(
        height: 100,
        width: 100,
      );
    }

    final height = MediaQuery.of(context).size.height;

    return SizedBox(
      height: height - 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Show icon
          _icon,
          Text(text,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
