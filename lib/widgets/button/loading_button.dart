import 'package:flutter/material.dart';

Widget loadingButton({required double size, Color? color}) {
  return Container(
    width: size,
    height: size,
    padding: const EdgeInsets.all(2.0),
    child: CircularProgressIndicator(
      color: color ?? Colors.white,
      strokeWidth: 2,
    ),
  );
}
