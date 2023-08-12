import 'dart:io';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/bot/bot_helper.dart';
import 'package:machi_app/widgets/image/image_source_sheet.dart';
import 'package:screenshot/screenshot.dart';

class CreateOutlineFooter extends StatefulWidget {
  const CreateOutlineFooter({
    Key? key,
  }) : super(key: key);

  @override
  State<CreateOutlineFooter> createState() => _CreateOutlineFooterState();
}

class _CreateOutlineFooterState extends State<CreateOutlineFooter> {
  late AppLocalizations _i18n;
  late TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ScreenshotController screenshotController = ScreenshotController();

  Offset offset = Offset.zero;

  File? attachmentPreview;
  String? galleryImageUrl;
  TextAlign textAlign = TextAlign.left;
  double _alphaValue = 0.5;
  double yOffset = 80;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.only(
          left: 10,
          right: 10,
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ListView(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [_attachmentPreview()],
      ),
    );
  }

  void _onComplete() async {
    String text = _textController.text;
    Uint8List? imageBytes;
    if ((attachmentPreview != null || galleryImageUrl != null) &&
        _textController.text != "") {
      imageBytes = await screenshotController.capture();
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
              attachmentPreview = image as File?;
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
    Size size = MediaQuery.of(context).size;
    double width = size.width - 40;

    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Screenshot(
              controller: screenshotController,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: offset.dx,
                    top: offset.dy + yOffset,
                    child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            offset = Offset(offset.dx + details.delta.dx,
                                offset.dy + details.delta.dy);
                          });
                        },
                        child: SizedBox(
                          width: width,
                          height: width,
                          child: TextFormField(
                            maxLines: null,
                            textAlign: TextAlign.center,
                            controller: _textController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: const TextStyle(
                                inherit: true,
                                color: APP_INVERSE_PRIMARY_COLOR,
                                shadows: [
                                  Shadow(
                                      // bottomLeft
                                      offset: Offset(-1.0, -1.0),
                                      color: APP_PRIMARY_COLOR),
                                  Shadow(
                                      // bottomRight
                                      offset: Offset(1.0, -1.0),
                                      color: APP_PRIMARY_COLOR),
                                  Shadow(
                                      // topRight
                                      offset: Offset(1.0, 1.0),
                                      color: APP_PRIMARY_COLOR),
                                  Shadow(
                                      // topLeft
                                      offset: Offset(-1.0, 1.0),
                                      color: APP_PRIMARY_COLOR),
                                ]),
                          ),
                        )),
                  ),
                ],
              )),
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
