import 'package:flutter/material.dart';
import 'package:fren_app/constants/constants.dart';

class NotificationCounter extends StatelessWidget {
  // Variables
  final Widget icon;
  final int counter;

  const NotificationCounter(
      {Key? key, required this.icon, required this.counter})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        icon,
        Positioned(
          right: 0,
          top: -5,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: APP_WARNING,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$counter',
              style: const TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.right,
            ),
          ),
        )
      ],
    );
  }
}
