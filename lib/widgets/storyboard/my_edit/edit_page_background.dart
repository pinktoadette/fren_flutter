import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/helpers/truncate_text.dart';
import 'package:machi_app/widgets/button/loading_button.dart';
import 'package:machi_app/widgets/image/image_source_sheet.dart';

// ignore: must_be_immutable
class EditPageBackground extends StatefulWidget {
  final Story passStory;
  double? alpha;
  String? backgroundImage;
  Function(File? data)? onImageSelect;
  Function(String? url)? onGallerySelect;
  Function(double alphaValue)? onAlphaChange;
  EditPageBackground(
      {Key? key,
      required this.passStory,
      this.alpha,
      this.backgroundImage,
      this.onImageSelect,
      this.onGallerySelect,
      this.onAlphaChange})
      : super(key: key);

  @override
  State<EditPageBackground> createState() => _EditPageBackgroundState();
}

class _EditPageBackgroundState extends State<EditPageBackground> {
  File? attachmentPreview;
  String? galleryImageUrl;
  late Story story;
  late AppLocalizations _i18n;
  double _alphaValue = 0.5;

  @override
  void initState() {
    super.initState();
    setState(() {
      story = widget.passStory;
      _alphaValue = widget.alpha ?? 0.5;
      galleryImageUrl = widget.backgroundImage;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _i18n = AppLocalizations.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _i18n.translate("creative_mix_background"),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(_i18n.translate("creative_mix_background_select"),
                    style: Theme.of(context).textTheme.labelMedium),
                const Divider(height: 5, thickness: 1),
                attachmentPreview != null || galleryImageUrl != null
                    ? _attachmentPreview()
                    : Container(
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            border: Border.all(
                                width: 1,
                                color: Colors.grey,
                                strokeAlign: BorderSide.strokeAlignCenter)),
                        height: 100,
                        width: 100,
                        child: IconButton(
                            onPressed: () {
                              _addImage();
                            },
                            icon: const Icon(Iconsax.image)),
                      ),
                const SizedBox(
                  height: 50,
                ),
                const Text("Alpha Value"),
                Slider(
                  value: _alphaValue,
                  max: 1,
                  divisions: 100,
                  label: _alphaValue.toString(),
                  onChanged: (double value) {
                    setState(() {
                      _alphaValue = value;
                    });
                    widget.onAlphaChange!(value);
                  },
                ),
              ],
            )));
  }

  void _addImage() async {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      builder: (context) => ImageSourceSheet(
        onImageSelected: (image) async {
          if (image != null) {
            setState(() {
              attachmentPreview = image;
              galleryImageUrl = null;
            });
            widget.onImageSelect!(image);
          }
        },
        onGallerySelected: (imageUrl) async {
          setState(() {
            galleryImageUrl = imageUrl;
            attachmentPreview = null;
          });
          widget.onGallerySelect!(imageUrl);
        },
      ),
    );
  }

  Widget _attachmentPreview() {
    return Stack(
      children: <Widget>[
        SizedBox(
          height: 120,
          width: 120,
          child: Card(
              child: SizedBox.fromSize(
                  size: const Size.fromRadius(48), // Image radius
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: galleryImageUrl != null
                        ? CachedNetworkImage(
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            progressIndicatorBuilder: (context, url,
                                    progress) =>
                                loadingButton(size: 16, color: Colors.black),
                            imageUrl: galleryImageUrl!,
                            fadeInDuration: const Duration(seconds: 1),
                            cacheManager: CacheManager(
                              Config(
                                'imageCache',
                                stalePeriod: const Duration(days: 14),
                              ),
                            ),
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            attachmentPreview!,
                            fit: BoxFit.fitHeight,
                            width: 120,
                            height: 120,
                          ),
                  ))),
        ),
        Positioned(
          top: 0,
          right: 5,
          child: GestureDetector(
            onTap: () {
              setState(() {
                attachmentPreview = null;
                galleryImageUrl = null;
              });
              widget.onGallerySelect!(null);
              widget.onImageSelect!(null);
            },
            child: const Icon(Iconsax.close_circle),
          ),
        ),
      ],
    );
  }
}
