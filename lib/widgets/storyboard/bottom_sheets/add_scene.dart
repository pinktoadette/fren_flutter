import 'dart:io';
import 'dart:math';

import 'package:fren_app/controller/storyboard_controller.dart';
import 'package:fren_app/datas/storyboard.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/helpers/uploader.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class AddSceneBoard extends StatefulWidget {
  final Storyboard story;
  const AddSceneBoard({Key? key, required this.story}) : super(key: key);

  @override
  _AddSceneBoardState createState() => _AddSceneBoardState();
}

class _AddSceneBoardState extends State<AddSceneBoard> {
  late AppLocalizations _i18n;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  File? _attachmentPreview;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Container(
        height: min(500, height * 0.4),
        padding: const EdgeInsets.all(10),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _i18n.translate("story_add_text_scene"),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        _onHandleSubmitScene();
                      },
                      child: Text(_i18n.translate("add")))
                ],
              ),
              SizedBox(
                  width: width,
                  child: TextFormField(
                    maxLength: 500,
                    maxLines: 10,
                    buildCounter: (_,
                            {required currentLength,
                            maxLength,
                            required isFocused}) =>
                        _counter(context, currentLength, maxLength),
                    controller: _textController,
                  )),
              const Spacer(),
            ]));
  }

  Widget _counter(BuildContext context, int currentLength, int? maxLength) {
    return Padding(
      padding: const EdgeInsets.only(left: 0.0),
      child: Container(
          alignment: Alignment.topLeft,
          child: Text(
            currentLength.toString() + "/" + maxLength.toString(),
            style: Theme.of(context).textTheme.labelSmall,
          )),
    );
  }

  void _onHandleSubmitScene() async {
    if (_attachmentPreview != null) {
      String uri = await uploadFile(
          file: _attachmentPreview!,
          category: 'scene',
          categoryId: widget.story.storyboardId);
    }
  }
}
