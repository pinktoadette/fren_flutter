import 'dart:io';

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class RoundedImage extends StatelessWidget {
  double? radius;
  bool? isLocal;
  double width;
  double height;

  /// if no photo, use icon
  Icon icon;
  final String photoUrl;

  RoundedImage(
      {Key? key,
      this.radius = 10,
      this.isLocal = false,
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
                ? _showPicture()
                : Container(
                    child: icon,
                  )));
  }

  Widget _showPicture() {
    if (isLocal == true) {
      return Image.asset(photoUrl);
    } else if (photoUrl.startsWith('https') == true) {
      return Image.network(
        photoUrl,
        fit: BoxFit.cover,
      );
    }
    return Image.file(
      File(photoUrl),
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }
}
