import 'package:get/get.dart';
import 'package:machi_app/constants/constants.dart';
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
class StoryBigHeaderWidget extends StatelessWidget {
  final Story story;
  const StoryBigHeaderWidget({Key? key, required this.story}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    double storyCoverWidth = 70;
    double padding = 20;
    return InkWell(
      onTap: () async {
        _showEditStory(context);
      },
      child: Container(
          height: 200,
          decoration: story.photoUrl != null && story.photoUrl != ""
              ? BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(story.photoUrl!),
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.topCenter,
                    colorFilter: ColorFilter.mode(
                        const Color.fromARGB(255, 213, 213, 213)
                            .withOpacity(0.9),
                        BlendMode.darken),
                  ),
                )
              : BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  shape: BoxShape.rectangle,
                  border:
                      Border.all(width: 1, color: APP_INVERSE_PRIMARY_COLOR)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      TimelineHeader(
                        paddingLeft: 0,
                        user: story.createdBy,
                        showAvatar: false,
                        showName: true,
                        fontSize: 12,
                        isChild: true,
                      ),
                      Text(story.title,
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          softWrap: false,
                          style: Theme.of(context).textTheme.labelMedium),
                      Text("${story.pages?.length ?? 0} pages",
                          style: Theme.of(context).textTheme.labelSmall),
                    ],
                  )),
                ],
              ),
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
