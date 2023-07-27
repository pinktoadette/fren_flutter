// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/machi/interactive_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/datas/interactive.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/create_uuid.dart';
import 'package:machi_app/helpers/uploader.dart';
import 'package:machi_app/screens/interactive/interactive_board_page.dart';
import 'package:machi_app/widgets/animations/loader.dart';
import 'package:machi_app/widgets/button/loading_button.dart';
import 'package:machi_app/widgets/common/no_data.dart';
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
  List<Map<String, String>>? _themes;
  Map<String, String>? _selectedTheme;
  File? attachmentPreview;
  String? galleryImageUrl;
  bool isLoading = false;

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
    List<Map<String, String>> themes =
        List.castFrom<dynamic, Map<String, String>>(decodedJson);
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
    return Column(
      children: [
        const Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Text("Select a theme")),
        _selectImage(),
        ..._themes!.map((theme) {
          return Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _themes!.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Text(
                                _themes![index]["name"]!,
                                style: const TextStyle(
                                    color: APP_MUTED_COLOR, fontSize: 14),
                              ),
                              Row(
                                children: [
                                  _buildBox(
                                      _themes![index]["backgroundColor"]!),
                                  _buildBox(_themes![index]["titleColor"]!),
                                  _buildBox(_themes![index]["bodyTextColor"]!),
                                ],
                              )
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        })
      ],
    );
  }

  Widget _buildBox(String theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      width: 100, // Adjust the width of the boxes as needed
      decoration: BoxDecoration(
        color: Color(
            int.parse(theme, radix: 16)), // You can change the color as needed
        borderRadius: BorderRadius.circular(10),
      ),
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
