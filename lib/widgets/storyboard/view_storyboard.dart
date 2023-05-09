import 'dart:typed_data';

import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/widgets/audio/play_control.dart';
import 'package:machi_app/widgets/storyboard/bottom_sheets/publish_items.dart';
import 'package:machi_app/widgets/storyboard/story_view.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

// view story board as the creator
class ViewStory extends StatefulWidget {
  bool? showName = false;
  ViewStory({Key? key, this.showName}) : super(key: key);

  @override
  _PreviewStoryState createState() => _PreviewStoryState();
}

class _PreviewStoryState extends State<ViewStory> {
  late AppLocalizations _i18n;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  Uint8List? bytes;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            color: Theme.of(context).primaryColor,
            onPressed: () async {
              Navigator.of(context).pop();
            },
          ),
          actions: [
            if (storyboardController.currentStory.status ==
                    StoryStatus.UNPUBLISHED &&
                storyboardController.currentStory.createdBy.userId ==
                    UserModel().user.userId)
              InkWell(
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Icon(Iconsax.menu),
                  ),
                  onTap: () {
                    _publish();
                  })
          ],
        ),
        body: SizedBox(
            height: height,
            child: Stack(
              children: [
                SingleChildScrollView(
                    physics: const ScrollPhysics(),
                    child: Stack(children: [
                      Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: Text(
                                storyboardController.currentStory.title,
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                            ),
                            StoryViewDetails(
                              story: storyboardController.currentStory,
                            ),
                            const SizedBox(
                              height: 250,
                            )
                          ])
                    ])),
                Positioned(bottom: 0, child: AudioWidget())
              ],
            )));
  }

  void _publish() async {
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        enableDrag: true,
        builder: (context) => PublishItemsWidget(
            story: storyboardController.currentStory,
            onCaptureImage: (isCapture) async {
              // if (isCapture == true) {
              //   Uint8List? bytes = await controller.capture();
              //   _accessStorage(bytes!);
              // }
            }));
  }
}
