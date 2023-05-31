import 'dart:io';

import 'package:flutter/material.dart';
import 'package:machi_app/constants/constants.dart';

/// Storyboard or story photoUrl cover
class StoryCover extends StatelessWidget {
  final String? photoUrl;
  final String title;
  final double? width;
  final double? height;
  final double? radius;
  final File? file;
  const StoryCover(
      {Key? key,
      this.radius,
      required this.photoUrl,
      required this.title,
      this.file,
      this.width,
      this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: APP_ACCENT_COLOR,
            borderRadius: BorderRadius.circular(radius ?? 20),
            boxShadow: [
              BoxShadow(
                  blurRadius: 8,
                  offset: const Offset(5, 15),
                  color: Theme.of(context)
                      .colorScheme
                      .tertiaryContainer
                      .withOpacity(.6),
                  spreadRadius: -9)
            ]),
        child: SizedBox(
            height: height ?? 120,
            width: width ?? 100,
            child: _showImageLocal(context)));
  }

  Widget _showImageLocal(BuildContext context) {
    if (photoUrl != "") {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius ?? 10.0),
        child: Image.network(
          photoUrl!,
          width: width ?? 120,
          fit: BoxFit.cover,
        ),
      );
    }
    if (file != null) {
      return ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image(
              image: FileImage(file!), width: width ?? 120, fit: BoxFit.cover));
    }
    return ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Center(
          child: Text(title.substring(0, 1).toUpperCase(),
              style: Theme.of(context).textTheme.headlineSmall),
        ));
  }
}
