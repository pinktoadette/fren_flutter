// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/animations/loader.dart';
import 'package:machi_app/widgets/button/loading_button.dart';
import 'package:machi_app/widgets/image/image_source_sheet.dart';

/// Creator can create from
/// 1. prompt, 2. board
class ThemePrompt extends StatefulWidget {
  const ThemePrompt({Key? key}) : super(key: key);

  @override
  _ThemePromptState createState() => _ThemePromptState();
}

class _ThemePromptState extends State<ThemePrompt> {
  late AppLocalizations _i18n;
  List<Map<String, dynamic>>? _themes;
  Map<String, dynamic>? _selectedTheme;
  File? attachmentPreview;
  String? galleryImageUrl;
  bool isLoading = false;
  double padding = 20;

  @override
  void initState() {
    super.initState();
    _loadThemes();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadThemes() async {
    String jsonContent = await rootBundle.loadString('assets/json/theme.json');
    List<dynamic> decodedJson = jsonDecode(jsonContent);
    List<Map<String, dynamic>> themes =
        List.castFrom<dynamic, Map<String, dynamic>>(decodedJson);
    setState(() {
      _themes = themes;
    });
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    if (_themes == null) {
      return const Center(
        child: Frankloader(),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _initialSelection(),
    );
  }

  Widget _initialSelection() {
    double width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Padding(
            padding: EdgeInsets.only(left: padding, right: padding),
            child: const Text("Select a theme")),
        _selectImage(),
        ..._themes!.map((theme) {
          return InkWell(
              onTap: () => setState(() {
                    _selectedTheme = theme;
                  }),
              child: Card(
                color: _selectedTheme == theme
                    ? APP_ACCENT_COLOR
                    : Theme.of(context).colorScheme.background,
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(padding / 2),
                  child: Column(
                    children: [
                      Text(
                        theme["name"]!,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      Row(
                        children: [
                          _buildBox(
                              theme: theme["backgroundColor"]!,
                              width: width,
                              showText: theme),
                          _buildBox(theme: theme["titleColor"]!, width: width),
                          _buildBox(
                              theme: theme["bodyTextColor"]!, width: width),
                        ],
                      )
                    ],
                  ),
                ),
              ));
        })
      ],
    );
  }

  Widget _buildBox(
      {required String theme,
      required double width,
      Map<String, dynamic>? showText}) {
    double w = (showText != null ? width / 2 : width / 4) - padding * 1.5;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.all(10),
      width: w,
      height: showText != null ? w / 2 : w,
      decoration: BoxDecoration(
        color: Color(int.parse("0xFF$theme")),
        borderRadius: BorderRadius.circular(10),
      ),
      child: showText != null
          ? Center(
              child: Column(
                children: [
                  Text("A Brown Fox Pangram",
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(
                              int.parse("0xFF${showText["titleColor"]}")))),
                  Text("A brown fox jumps over the lazy dog.",
                      style: TextStyle(
                          fontSize: 10,
                          color: Color(
                              int.parse("0xFF${showText["bodyTextColor"]}"))))
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _selectImage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 20,
                ),
                child: attachmentPreview != null || galleryImageUrl != null
                    ? _attachmentPreview()
                    : Container(
                        height: 70,
                        width: 70,
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            border: Border.all(
                                width: 1,
                                color: Colors.grey,
                                strokeAlign: BorderSide.strokeAlignCenter)),
                        child: IconButton(
                            onPressed: () {
                              _addImage();
                            },
                            icon: const Icon(Iconsax.image)),
                      )),
          ],
        ),
      ],
    );
  }

  Widget _attachmentPreview() {
    // @todo remove. duplicate fuction
    return Stack(
      children: <Widget>[
        SizedBox(
          height: 70,
          width: 70,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(10), // Image border
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
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            attachmentPreview!,
                            fit: BoxFit.fitHeight,
                            width: 70,
                            height: 70,
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
            },
            child: const Icon(Iconsax.close_circle),
          ),
        ),
      ],
    );
  }

  void _addImage() async {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      builder: (context) => ImageSourceSheet(
        onImageSelected: (image) async {
          if (image != null) {
            Navigator.pop(context);
            setState(() {
              attachmentPreview = image;
              galleryImageUrl = null;
            });
          }
        },
        onGallerySelected: (imageUrl) async {
          setState(() {
            galleryImageUrl = imageUrl;
            attachmentPreview = null;
          });
          Navigator.pop(context);
        },
      ),
    );
  }
}
