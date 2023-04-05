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
    int finalCounter = counter;
    if (counter > 1000) {
      finalCounter = (counter / 1000).ceil();
    }

    return Stack(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(top: 5, right: 20),
          child: icon,
        ),
        Positioned(
          right: 0,
          top: -2,
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 5),
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: APP_ACCENT_COLOR,
              shape: BoxShape.circle,
            ),
            child: Align(
                alignment: Alignment.center,
                child: Text(
                  '$finalCounter',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                  ),
                )),
          ),
        )
      ],
    );
  }
}
