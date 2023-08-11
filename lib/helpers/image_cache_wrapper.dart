import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

// ignore: non_constant_identifier_names
ImageProvider<Object> ImageCacheWrapper(String imageUrl) {
  // Your custom logic to check for conditions
  bool isValidUrl = isValidImageUrl(imageUrl);

  if (isValidUrl) {
    try {
      return CachedNetworkImageProvider(
        imageUrl,
        errorListener: () async {
          await _flagImage(imageUrl);
          return;
        },
      );
    } catch (_) {
      return BlankImageProvider(10, 10);
    }
  } else {
    return const AssetImage(
      "assets/images/blank.png",
    );
  }
}

/// save the failed image and dont show it again in the future.
Future<void> _flagImage(String imageUrl) async {
  try {
    debugPrint("======= Image returned 404 =========");
    debugPrint("Image url returns 404 $imageUrl");
  } catch (error) {
    return;
  }
}

bool isValidImageUrl(String imageUrl) {
  return imageUrl.isNotEmpty &&
      (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));
}

class BlankImageProvider extends ImageProvider<BlankImageProvider> {
  final double width;
  final double height;

  BlankImageProvider(this.width, this.height);

  @override
  Future<BlankImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<BlankImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
      BlankImageProvider key, ImageDecoderCallback decode) {
    throw UnimplementedError(
        "BlankImageProvider doesn't actually load any image data.");
  }
}
