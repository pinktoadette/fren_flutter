import 'package:flutter/material.dart';

class NotificationCounter extends StatelessWidget {
  // Variables
  final Widget icon;
  final int counter;
  final double? iconPadding;

  const NotificationCounter(
      {Key? key, required this.icon, required this.counter, this.iconPadding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int finalCounter = counter;
    if (counter > 100) {
      finalCounter = (counter / 100).ceil();
    }

    return Container(
      padding: EdgeInsets.only(right: iconPadding ?? 0),
      child: Badge(
        label: Text(finalCounter.toString()),
        child: icon,
      ),
    );
  }
}
