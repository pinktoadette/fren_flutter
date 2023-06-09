import 'package:get/get.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/widgets/story_cover.dart';
import 'package:machi_app/widgets/storyboard/story/storyboard_edit.dart';
import 'package:machi_app/widgets/storyboard/story/storyboard_info.dart';
import 'package:machi_app/widgets/timeline/timeline_header.dart';

class StoryboardHeaderWidget extends StatefulWidget {
  const StoryboardHeaderWidget({Key? key}) : super(key: key);

  @override
  _StoryboardHeaderWidgetState createState() => _StoryboardHeaderWidgetState();
}

class _StoryboardHeaderWidgetState extends State<StoryboardHeaderWidget> {
  StoryboardController storyboardController = Get.find(tag: "storyboard");

  @override
  Widget build(BuildContext context) {
    Storyboard storyboard = storyboardController.currentStoryboard;
    double width = MediaQuery.of(context).size.width;
    double storyCoverWidth = 150;
    double padding = 15;

    return Obx(() => InkWell(
        onTap: () {
          _showEditStoryboard(context);
        },
        child: Card(
            elevation: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                TimelineHeader(
                  user: storyboard.createdBy,
                  showAvatar: true,
                  showName: true,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(padding),
                      child: StoryCover(
                          width: storyCoverWidth,
                          height: storyCoverWidth,
                          photoUrl:
                              storyboardController.currentStoryboard.photoUrl ??
                                  "",
                          title: storyboard.title),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(storyboardController.currentStoryboard.category,
                            style: const TextStyle(
                                fontSize: 10,
                                color: APP_SECONDARY_ACCENT_COLOR,
                                fontWeight: FontWeight.bold)),
                        SizedBox(
                          width: width - (padding * 2 + storyCoverWidth + 10),
                          height: 25,
                          child: Text(storyboard.title,
                              style: Theme.of(context).textTheme.labelMedium),
                        ),
                        Text("${storyboard.story?.length ?? 0} collection",
                            style: Theme.of(context).textTheme.labelSmall)
                      ],
                    )
                  ],
                ),
              ],
            ))));
  }

  void _showEditStoryboard(BuildContext context) {
    StoryboardController storyboardController = Get.find(tag: "storyboard");
    bool showInfo = true;
    if ((storyboardController.currentStoryboard.createdBy.userId ==
            UserModel().user.userId) &
        (storyboardController.currentStoryboard.status !=
            StoryStatus.PUBLISHED)) {
      showInfo = false;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      builder: (context) => FractionallySizedBox(
          heightFactor: 0.9,
          child: DraggableScrollableSheet(
            snap: true,
            initialChildSize: 1,
            minChildSize: 0.9,
            builder: (context, scrollController) => SingleChildScrollView(
              controller: scrollController,
              child: showInfo == false
                  ? const StoryboardEdit()
                  : const StoryboardInfo(),
            ),
          )),
    );
  }
}
