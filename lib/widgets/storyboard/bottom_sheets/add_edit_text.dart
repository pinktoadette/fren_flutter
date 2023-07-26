import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/widgets/bot/bot_helper.dart';
import 'package:machi_app/widgets/button/loading_button.dart';
import 'package:machi_app/widgets/common/app_logo.dart';
import 'package:machi_app/widgets/image/image_source_sheet.dart';

class AddEditText extends StatefulWidget {
  final String? text;
  final Function(Map<String, dynamic>?) onTextComplete;
  const AddEditText({Key? key, required this.onTextComplete, this.text})
      : super(key: key);

  @override
  _AddEditTextState createState() => _AddEditTextState();
}

class _AddEditTextState extends State<AddEditText> {
  late AppLocalizations _i18n;
  late TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  File? attachmentPreview;
  String? galleryImageUrl;
  TextAlign textAlign = TextAlign.left;

  @override
  void initState() {
    super.initState();
    if (widget.text != null) {
      _textController = TextEditingController(text: widget.text);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double height = MediaQuery.of(context).size.height;

    return Container(
        height: height - 90,
        padding: EdgeInsets.only(
            top: 10,
            left: 10,
            right: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Stack(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_i18n.translate("story_add_text_scene"),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(0, 0),
                        padding: const EdgeInsets.all(5),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        _onComplete(_textController.text);
                      },
                      child: widget.text == null
                          ? Text(
                              _i18n.translate("add"),
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 14),
                            )
                          : Text(
                              _i18n.translate("UPDATE"),
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 14),
                            ))
                ],
              ),
              Row(
                children: [
                  attachmentPreview != null || galleryImageUrl != null
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
                        ),
                  Container(
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
                          _showHelperDetails();
                        },
                        icon: const AppLogo()),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          textAlign = TextAlign.left;
                        });
                      },
                      icon: const Icon(Icons.align_horizontal_left)),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          textAlign = TextAlign.center;
                        });
                      },
                      icon: const Icon(Icons.align_horizontal_center)),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          textAlign = TextAlign.right;
                        });
                      },
                      icon: const Icon(Icons.align_horizontal_right)),
                ],
              )
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 200),
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: ConstrainedBox(
                    constraints: const BoxConstraints(),
                    child: TextFormField(
                      textAlign: textAlign,
                      scrollController: _scrollController,
                      style: Theme.of(context).textTheme.bodyMedium,
                      onTapOutside: (b) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: _i18n.translate("story_write_edit"),
                        hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      onChanged: (value) => {print(value)},
                      controller: _textController,
                      scrollPadding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                    ))),
          )
        ]));
  }

  void _onComplete(String text) {
    if (text.length > 3 ||
        attachmentPreview != null ||
        galleryImageUrl != null) {
      widget.onTextComplete({
        "text": text,
        "image": attachmentPreview ?? "",
        "gallery": galleryImageUrl ?? "",
        "textAlign": textAlign
      });
    } else {
      Get.snackbar(
        _i18n.translate("validation_warning"),
        _i18n.translate("story_content_validation"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_WARNING,
      );
    }
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

  Widget _attachmentPreview() {
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

  _showHelperDetails() {
    String text = "";
    if (_textController.selection.isValid == true &&
        _textController.selection.textInside(_textController.text) != "") {
      text = _textController.selection.textInside(_textController.text);
    } else {
      text = _textController.text;
    }

    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) => FractionallySizedBox(
            heightFactor: 0.55,
            child: DraggableScrollableSheet(
              snap: true,
              initialChildSize: 1,
              minChildSize: 0.9,
              builder: (context, scrollController) => SingleChildScrollView(
                  controller: scrollController,
                  child: MachiHelper(
                      onTextReplace: (value) => {
                            if (_textController.selection.isValid == false)
                              {_textController.text = value}
                            else
                              {_replaceText(value)}
                          },
                      text: text)),
            )));
  }

  void _replaceText(String newText) {
    final int start = _textController.selection.start;
    final int end = _textController.selection.end;

    // Get the original text
    String originalText = _textController.text;

    String textBeforeSelection = originalText.substring(0, start);
    String textAfterSelection = originalText.substring(end);

    // Combine the parts with the new text
    String replacedText = textBeforeSelection + newText + textAfterSelection;

    // Update the text controller with the replaced text and the correct selection
    _textController.value = TextEditingValue(
      text: replacedText,
      selection: TextSelection(
        baseOffset: start,
        extentOffset: start + newText.length,
      ),
    );

    Get.snackbar(_i18n.translate("success"), "Text is replaced",
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_SUCCESS,
        colorText: Colors.black);
  }
}
