import 'package:get/get.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/widgets/storyboard/story/story_edit.dart';
import 'package:machi_app/widgets/story_cover.dart';
import 'package:machi_app/widgets/storyboard/story/story_info.dart';
import 'package:machi_app/widgets/timeline/timeline_header.dart';

// Story book Onboarding swipe -> child : story_widget
class StoryHeaderWidget extends StatelessWidget {
  final Story story;
  const StoryHeaderWidget({Key? key, required this.story}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    double storyCoverWidth = 50;
    double padding = 20;
    return InkWell(
      onTap: () async {
        _showEditStory(context);
      },
      child: Container(
          padding: EdgeInsets.only(left: padding, bottom: 5, right: padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              TimelineHeader(
                user: story.createdBy,
                showAvatar: true,
                showName: true,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  StoryCover(
                      width: storyCoverWidth,
                      height: storyCoverWidth,
                      photoUrl: story.photoUrl ?? "",
                      title: story.title),
                  const SizedBox(width: 10),
                  Flexible(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(story.title,
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          softWrap: false,
                          style: Theme.of(context).textTheme.labelMedium),
                      Text("${story.pages?.length ?? 0} pages",
                          style: Theme.of(context).textTheme.labelSmall)
                    ],
                  ))
                ],
              )
            ],
          )),
    );
  }

  void _showEditStory(BuildContext context) {
    StoryboardController storyboardController = Get.find(tag: "storyboard");
    bool showInfo = true;
    if ((storyboardController.currentStory.createdBy.userId ==
            UserModel().user.userId) &
        (storyboardController.currentStory.status != StoryStatus.PUBLISHED)) {
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
                        ? const StoryEdit()
                        : const StoryInfo()),
              ),
            ));
  }
}
