import 'package:flutter/material.dart';

class AspectRatioImage {
  double imageWidth;
  double imageHeight;
  String imageUrl;

  AspectRatioImage({
    required this.imageWidth,
    required this.imageHeight,
    required this.imageUrl,
  });

  AspectRatioImage displayScript(Size mediaSize) {
    double maxWidth = mediaSize.width - 50;
    double width = maxWidth < imageWidth ? maxWidth : 512;

    if (imageWidth == imageHeight) {
      return AspectRatioImage(
          imageWidth: width, imageHeight: width, imageUrl: imageUrl);
    } else {
      double aspectRatio = imageWidth / imageHeight;
      double height = width / aspectRatio;

      return AspectRatioImage(
          imageWidth: width, imageHeight: height, imageUrl: imageUrl);
    }
  }
}
