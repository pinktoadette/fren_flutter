import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

ImageProvider<Object> imageCacheWrapper(String imageUrl) {
  // Your custom logic to check for conditions
  bool isValidUrl = isValidImageUrl(imageUrl);

  if (isValidUrl) {
    return CachedNetworkImageProvider(
      imageUrl,
      errorListener: () => const Icon(Icons.error),
    );
  } else {
    // You can return a placeholder image or any other default image provider here
    // For example, AssetImage('path_to_placeholder_image')
    // If you don't want to show any image, return an empty ImageProvider
    return const AssetImage(
      "assets/images/blank.png",
    );
  }
}

bool isValidImageUrl(String imageUrl) {
  return imageUrl.isNotEmpty &&
      (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));
}
