import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/widgets/button/loading_button.dart';

/// Storyboard or story photoUrl cover
class StoryCover extends StatefulWidget {
  final String photoUrl;
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
  State<StoryCover> createState() => _StoryCoverState();
}

class _StoryCoverState extends State<StoryCover> {
  @override
  Widget build(BuildContext context) {
    if (widget.icon != null) {
      return Container(
          decoration: BoxDecoration(
              color: APP_ACCENT_COLOR,
              borderRadius: BorderRadius.circular(widget.radius ?? 10),
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
              height: widget.height ?? 120,
              width: widget.width ?? 120,
              child: Stack(children: [
                _showImageLocal(context),
                Positioned(bottom: 0, right: 0, child: widget.icon!)
              ])));
    }

    return Card(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius ?? 10),
        child: SizedBox(
          height: widget.height ?? 512,
          width: widget.width ?? 512,
          child: _showImageLocal(context),
        ),
      ),
    );
  }

  Widget _showImageLocal(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    if (widget.photoUrl != "") {
      int width = (widget.width ?? 512).toInt();
      int height = (widget.height ?? 512).toInt();

      return CachedNetworkImage(
        fit: BoxFit.cover,
        width: widget.width ?? 512,
        height: widget.height ?? 512,
        memCacheWidth: width,
        memCacheHeight: height,
        imageUrl: widget.photoUrl,
        cacheManager: CacheManager(
          Config(
            'imageCache',
            stalePeriod: const Duration(days: 7),
          ),
        ),
        progressIndicatorBuilder: (context, url, progress) =>
            loadingButton(size: 20),
        errorWidget: (context, url, error) => const Icon(Iconsax.gallery_slash),
      );
    }
    if (widget.file != null) {
      return ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image(
              image: FileImage(widget.file!),
              width: widget.width ?? 120,
              fit: BoxFit.cover));
    }
    return Container(
      height: size.height - 100,
      width: size.width - 100.0,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Theme.of(context).colorScheme.background),
      child: const Center(child: Icon(Iconsax.gallery)),
    );
  }
}
