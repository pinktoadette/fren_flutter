import 'dart:io';
import 'dart:typed_data';

import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/storyboard_controller.dart';
import 'package:fren_app/datas/storyboard.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/widgets/storyboard/bottom_sheets/publish_items.dart';
import 'package:fren_app/widgets/storyboard/story_view.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class PreviewStory extends StatefulWidget {
  final Storyboard story;
  bool? showName = false;
  PreviewStory({Key? key, required this.story, this.showName})
      : super(key: key);

  @override
  _PreviewStoryState createState() => _PreviewStoryState();
}

class _PreviewStoryState extends State<PreviewStory> {
  late AppLocalizations _i18n;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  WidgetsToImageController controller = WidgetsToImageController();
  Uint8List? bytes;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            _i18n.translate("storyboard_preview"),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          leading: BackButton(
            color: Theme.of(context).primaryColor,
            onPressed: () async {
              Navigator.of(context).pop();
            },
          ),
          actions: [
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  child: Text(_i18n.translate("publish")),
                  onPressed: () {
                    _publish();
                  },
                ))
          ],
        ),
        body: SingleChildScrollView(
            physics: const ScrollPhysics(),
            child: WidgetsToImage(
                controller: controller,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(left: 20, bottom: 20),
                          child: Text(
                            widget.story.title,
                            style: Theme.of(context).textTheme.headlineMedium,
                            textAlign: TextAlign.left,
                          )),
                      StoryView(story: widget.story, shownames: widget.showName)
                    ]))));
  }

  void _publish() async {
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        enableDrag: true,
        builder: (context) => PublishItemsWidget(
            story: widget.story,
            onCaptureImage: (isCapture) async {
              if (isCapture == true) {
                Uint8List? bytes = await controller.capture();
                _accessStorage(bytes!);
              }
            }));
  }

  void _accessStorage(Uint8List bytes) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    if (await Permission.storage.request().isGranted) {
      try {
        // @todo android only
        Directory dir = Directory('/storage/emulated/0/Download');
        String path = dir.path;

        await File(path).writeAsBytes(bytes);
      } catch (e) {
        Get.snackbar(
          _i18n.translate("error"),
          _i18n.translate("an_error_has_occurred"),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: APP_ERROR,
        );
      }
    }
  }
}
