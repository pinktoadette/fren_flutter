import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/main.dart';
import 'package:flutter/material.dart';

void showScaffoldMessage({
  BuildContext? context, // removed
  required String message,
  Color? bgcolor,
  Duration? duration,
}) {
  scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
    content: Text(message,
        style: const TextStyle(fontSize: 16, color: Colors.white)),
    duration: duration ?? const Duration(seconds: 5),
    backgroundColor: bgcolor ?? APP_PRIMARY_COLOR,
    margin: const EdgeInsets.only(left: 20, right: 20, bottom: 50),
    behavior: SnackBarBehavior.floating,
  ));
}
