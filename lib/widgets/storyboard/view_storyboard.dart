import 'dart:typed_data';

import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/widgets/story_cover.dart';
import 'package:machi_app/widgets/storyboard/bottom_sheets/publish_items.dart';
import 'package:machi_app/widgets/storyboard/view_story.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

// view story board as the creator
class ViewStoryboard extends StatefulWidget {
  bool? showName = false;
  ViewStoryboard({Key? key, this.showName}) : super(key: key);

  @override
  _PreviewStoryboardState createState() => _PreviewStoryboardState();
}

class _PreviewStoryboardState extends State<ViewStoryboard> {
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
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          title: Text(
            storyboardController.currentStory.title,
            style: Theme.of(context).textTheme.headlineMedium,
            overflow: TextOverflow.fade,
          ),
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
            else
              IconButton(
                  onPressed: () {
                    _showAudioList();
                  },
                  icon: const Icon(Iconsax.sound))
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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (storyboardController.currentStory.photoUrl !=
                                "")
                              StoryCover(
                                  width: width * 0.7,
                                  height: width * 0.7,
                                  photoUrl: storyboardController
                                      .currentStory.photoUrl,
                                  title:
                                      storyboardController.currentStory.title),
                            Container(
                              width: width,
                              height: 120,
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(Iconsax.book),
                                  Text(
                                    _i18n.translate("story_as_text"),
                                  )
                                ],
                              ),
                            ),
                          ])
                    ])),
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
            onCaptureImage: (isCapture) async {}));
  }

  void _showAudioList() {
    showModalBottomSheet(
        context: context,
        builder: (context) => ViewStory(
              storyboard: storyboardController.currentStory,
            ));
  }
}
