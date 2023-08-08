import 'dart:io';
import 'dart:typed_data';

import 'package:iconsax/iconsax.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/script.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/helpers/image_cache_wrapper.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/widgets/bot/bot_helper.dart';
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

  Offset offset = Offset.zero;

  File? attachmentPreview;
  String? galleryImageUrl;
  TextAlign textAlign = TextAlign.left;
  double _alphaValue = 0.5;

  @override
  void initState() {
    super.initState();
    setState(() {
      galleryImageUrl = widget.script?.image?.uri;
    });
    _textController =
        TextEditingController(text: widget.script?.text ?? "Text");
    textAlign = widget.script?.textAlign ?? TextAlign.left;
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

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: false,
          titleSpacing: 0,
          title: Text(
            _i18n.translate("story_add_text_scene"),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
                onPressed: () {
                  _onComplete();
                },
                child: widget.script?.text == null
                    ? Text(
                        _i18n.translate("add"),
                      )
                    : Text(
                        _i18n.translate("UPDATE"),
                      ))
          ],
        ),
        body: Container(
          padding: EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: ListView(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (attachmentPreview == null && galleryImageUrl == null)
                ..._showTextEdits()
              else
                _attachmentPreview()
            ],
          ),
        ));
  }

  void _onComplete() async {
    String text = _textController.text;
    Uint8List? _imageBytes;
    if ((attachmentPreview != null || galleryImageUrl != null) &&
        _textController.text != "") {
      _imageBytes = await screenshotController.capture();
    }

    widget.onTextComplete({
      "text": _imageBytes == null ? text : "",
      "byteImage": _imageBytes ?? "",
      "image": _imageBytes == null ? attachmentPreview ?? "" : "",
      "gallery": _imageBytes == null ? galleryImageUrl ?? "" : "",
      "textAlign": textAlign,
      "characterId": widget.script?.characterId ?? UserModel().user.userId
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
                  ClipRRect(
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
                      )),
                  Positioned(
                    left: offset.dx,
                    top: offset.dy,
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

  List<Widget> _showTextEdits() {
    Size size = MediaQuery.of(context).size;
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              attachmentPreview != null || galleryImageUrl != null
                  ? _attachmentPreview()
                  : IconButton(
                      onPressed: () {
                        _addImage();
                      },
                      icon: const Icon(Iconsax.image)),
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
          IconButton(
              onPressed: () {
                _showHelperDetails();
              },
              icon: const Icon(Icons.lightbulb_outlined)),
        ],
      ),
      Container(
          height: size.height - 160,
          width: MediaQuery.of(context).size.width,
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: const AlwaysScrollableScrollPhysics(),
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
                  hintStyle:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
                controller: _textController,
              ))),
    ];
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
        snackPosition: SnackPosition.TOP, backgroundColor: APP_SUCCESS);
  }
}
