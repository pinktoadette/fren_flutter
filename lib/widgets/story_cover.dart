import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/widgets/button/loading_button.dart';

/// Storyboard or story photoUrl cover
class StoryCover extends StatelessWidget {
  final String? photoUrl;
  final String title;
  final double? width;
  final double? height;
  final double? radius;
  final File? file;
  final Icon? icon;
  const StoryCover(
      {Key? key,
      this.radius,
      required this.photoUrl,
      required this.title,
      this.file,
      this.width,
      this.height,
      this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
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
              width: width ?? 120,
              child: Stack(children: [
                _showImageLocal(context),
                Positioned(bottom: 0, right: 0, child: icon!)
              ])));
    }

    return Container(
        decoration: BoxDecoration(
            color: APP_TERTIARY,
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
          width: width ?? 120,
          child: _showImageLocal(context),
        ));
  }

  Widget _showImageLocal(BuildContext context) {
    double w = width ?? 120;
    if (photoUrl != "") {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius ?? 10.0),
        child: CachedNetworkImage(
          progressIndicatorBuilder: (context, url, progress) =>
              loadingButton(size: 16, color: Colors.black),
          imageUrl: photoUrl!,
          fadeInDuration: const Duration(seconds: 1),
          width: w,
          height: w,
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
    return Container(
      height: 190.0,
      width: MediaQuery.of(context).size.width - 100.0,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.black,
          image: const DecorationImage(
              image: AssetImage("assets/images/chips.png"), fit: BoxFit.fill)),
      child: Center(
          child: Text(title.substring(0, 1).toUpperCase(),
              style: radius == 5
                  ? Theme.of(context).textTheme.labelSmall
                  : Theme.of(context).textTheme.headlineSmall)),
    );
  }
}
