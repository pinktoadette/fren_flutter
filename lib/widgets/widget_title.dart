import 'package:fren_app/widgets/svg_icon.dart';
import 'package:flutter/material.dart';

class WidgetTitle extends StatelessWidget {
  final IconData? icon;
  final String title;

  const WidgetTitle({Key? key, this.icon, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Title
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 40),
          child: Row(
            children: [
              if (icon != null)
                Icon(icon),

              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 5),
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        color:  Colors.grey,
                        fontWeight: FontWeight.w200)),
              )
            ],
          ),
        ),

      ],
    );

  }
}
