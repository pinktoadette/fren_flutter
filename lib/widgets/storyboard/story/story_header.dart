import 'package:get/get.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/screens/storyboard/edit_story.dart';
import 'package:machi_app/widgets/story_cover.dart';
import 'package:machi_app/widgets/storyboard/story/story_info.dart';

// Story book Onboarding swipe -> child : story_widget
class StoryHeaderWidget extends StatelessWidget {
  final Story story;
  const StoryHeaderWidget({Key? key, required this.story}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    double storyCoverWidth = 50;
    double padding = 15;

    return InkWell(
        onTap: () async {
          _showEditStory(context);
        },
        child: Card(
          elevation: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(padding),
                child: StoryCover(
                    width: storyCoverWidth,
                    height: storyCoverWidth,
                    photoUrl: story.photoUrl ?? "",
                    title: story.title),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(story.title,
                      overflow: TextOverflow.fade,
                      style: Theme.of(context).textTheme.labelMedium),
                  Text(story.subtitle,
                      style: Theme.of(context).textTheme.displaySmall),
                  Text("${story.pages?.length ?? 0} mods",
                      style: Theme.of(context).textTheme.labelSmall)
                ],
              )
            ],
          ),
        ));
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
                        ? const EditStory()
                        : const StoryInfo()),
              ),
            ));
  }
}
