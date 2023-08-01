import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/script.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/helpers/image_cache_wrapper.dart';
import 'package:machi_app/widgets/bot/bot_helper.dart';
import 'package:machi_app/widgets/button/loading_button.dart';
import 'package:machi_app/widgets/common/app_logo.dart';
import 'package:machi_app/widgets/decoration/text_border.dart';
import 'package:machi_app/widgets/image/image_source_sheet.dart';
import 'package:screenshot/screenshot.dart';

class AddEditText extends StatefulWidget {
  final Script? script;
  final Function(Map<String, dynamic>?) onTextComplete;
  const AddEditText({Key? key, required this.onTextComplete, this.script})
      : super(key: key);

  @override
  _AddEditTextState createState() => _AddEditTextState();
}

class _AddEditTextState extends State<AddEditText> {
  late AppLocalizations _i18n;
  late TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ScreenshotController screenshotController = ScreenshotController();

  File? attachmentPreview;
  String? galleryImageUrl;
  TextAlign textAlign = TextAlign.left;
  double _alphaValue = 0.5;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    if (widget.script?.text != null) {
      _textController = TextEditingController(text: widget.script!.text);
      textAlign = widget.script?.textAlign ?? TextAlign.left;
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
    Size size = MediaQuery.of(context).size;

    return Container(
      height: size.height - 90,
      padding: EdgeInsets.only(
          top: 10,
          left: 10,
          right: 10,
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
          child: Column(
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
                  child: widget.script?.text == null
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
                  ? _attachmentPreview(context)
                  : Container(
                      height: 70,
                      width: 70,
                      margin:
                          const EdgeInsets.only(top: 10, left: 5, bottom: 10),
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
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 70,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
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
              ),
            ],
          ),
          SingleChildScrollView(
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
                    controller: _textController,
                    scrollPadding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                  ))),
        ],
      )),
    );
  }

  void _onComplete(String text) async {
    Uint8List? image = await screenshotController.capture();
    setState(() {
      _imageBytes = image;
    });

    widget.onTextComplete({
      "text": image == null ? text : "",
      "byteImage": _imageBytes ?? "",
      "image": image != null ? "" : attachmentPreview,
      "gallery": image != null ? "" : galleryImageUrl,
      "textAlign": textAlign
    });
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

  Widget _attachmentPreview(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = size.width - 40;
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: <Widget>[
              Screenshot(
                  controller: screenshotController,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Container(
                          height: width,
                          width: width,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  colorFilter: ColorFilter.mode(
                                      const Color.fromARGB(255, 0, 0, 0)
                                          .withOpacity(_alphaValue),
                                      BlendMode.darken),
                                  image: galleryImageUrl != null
                                      ? imageCacheWrapper(
                                          galleryImageUrl!,
                                        )
                                      : FileImage(attachmentPreview!),
                                  fit: BoxFit.cover)),
                          child: TextBorder(
                            text: _textController.text,
                            textAlign: textAlign,
                            size: 16,
                          )))),
              Positioned(
                top: 0,
                right: 5,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      attachmentPreview = null;
                      galleryImageUrl = null;
                      _imageBytes = null;
                    });
                  },
                  child: const Icon(Iconsax.close_circle),
                ),
              ),
            ],
          ),
          SizedBox(
            width: width,
            child: Slider(
              value: _alphaValue,
              max: 1,
              divisions: 100,
              label: _alphaValue.toString(),
              onChanged: (double value) {
                setState(() {
                  _alphaValue = value;
                });
              },
            ),
          )
        ]);
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
            heightFactor: MODAL_HEIGHT_SMALL_FACTOR,
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
