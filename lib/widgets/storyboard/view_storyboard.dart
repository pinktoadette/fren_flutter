import 'dart:typed_data';

import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/widgets/storyboard/bottom_sheets/publish_items.dart';
import 'package:machi_app/widgets/storyboard/story/listen_audio_story.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

// view story board as the creator
class ViewStoryboard extends StatefulWidget {
  bool? showName = false;
  ViewStoryboard({Key? key, this.showName}) : super(key: key);

  @override
  _ViewStoryboardState createState() => _ViewStoryboardState();
}

class _ViewStoryboardState extends State<ViewStoryboard> {
  late AppLocalizations _i18n;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  final _storyApi = StoryApi();
  Uint8List? bytes;
  late Story story;

  @override
  void initState() {
    super.initState();
    _getScriptByStoryId();
  }

  void _getScriptByStoryId() async {
    Story current = storyboardController.currentStory;

    /// Getting scripts
    Story details = await _storyApi.getMyStories(current.storyId);
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          title: Text(
            storyboardController.currentStoryboard.title,
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
            if (storyboardController.currentStoryboard.status ==
                    StoryStatus.UNPUBLISHED &&
                storyboardController.currentStoryboard.createdBy.userId ==
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
            child: const Stack(
              children: [
                SingleChildScrollView(
                    physics: ScrollPhysics(),
                    child: Stack(children: [
                      Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [Text("list stories")])
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
            story: storyboardController.currentStoryboard,
            onCaptureImage: (isCapture) async {}));
  }

  void _showAudioList() {
    showModalBottomSheet(
        context: context,
        builder: (context) => ViewAudioStory(
              storyboard: storyboardController.currentStoryboard,
            ));
  }
}
