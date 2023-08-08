import 'package:flutter/material.dart';
import 'package:machi_app/constants/constants.dart';

Widget loadingButton({required double size, Color? color}) {
  return Container(
    width: size,
    height: size,
    padding: const EdgeInsets.all(2.0),
    child: CircularProgressIndicator(
      color: color ?? APP_PRIMARY_COLOR,
      strokeWidth: 2,
    ),
  );
}
