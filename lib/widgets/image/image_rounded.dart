import 'dart:io';

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class RoundedImage extends StatelessWidget {
  double? radius;
  double width;
  double height;

  /// if no photo, use icon
  Icon icon;
  final String photoUrl;

  RoundedImage(
      {Key? key,
      this.radius = 10,
      required this.width,
      required this.height,
      required this.icon,
      required this.photoUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: width,
        height: height,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: photoUrl != ""
                ? photoUrl.startsWith('https') == true
                    ? Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(photoUrl),
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                : Container(
                    child: icon,
                  )));
  }
}
