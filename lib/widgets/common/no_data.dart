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
    late Widget icon;
    // Check svgName
    if (svgName != null) {
      // Get SVG icon
      icon = const Icon(Icons.error);
    } else {
      icon = const Frankloader(
        height: 100,
        width: 100,
      );
    }

    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // Show icon
        icon,
        Text(text,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center),
      ],
    ));
  }
}
