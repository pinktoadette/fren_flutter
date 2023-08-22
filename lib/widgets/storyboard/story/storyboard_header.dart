import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/widgets/story_cover.dart';
import 'package:machi_app/widgets/storyboard/story/storyboard_edit.dart';
import 'package:machi_app/widgets/storyboard/story/storyboard_info.dart';

class StoryboardHeaderWidget extends StatefulWidget {
  const StoryboardHeaderWidget({Key? key}) : super(key: key);

  @override
  State<StoryboardHeaderWidget> createState() => _StoryboardHeaderWidgetState();
}

class _StoryboardHeaderWidgetState extends State<StoryboardHeaderWidget> {
  StoryboardController storyboardController = Get.find(tag: "storyboard");

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double storyCoverWidth = 150;
    double padding = 15;

    return Obx(() {
      final currentStoryboard = storyboardController.currentStoryboard;

      return InkWell(
        onTap: () {
          _showEditStoryboard(context);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(padding),
              child: StoryCover(
                width: storyCoverWidth,
                height: storyCoverWidth,
                photoUrl: currentStoryboard.photoUrl ?? "",
                title: currentStoryboard.title,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentStoryboard.category,
                  style: const TextStyle(
                    fontSize: 10,
                    color: APP_SECONDARY_ACCENT_COLOR,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: width - (padding * 2 + storyCoverWidth + 10),
                  height: 25,
                  child: Text(
                    currentStoryboard.title,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                Text(
                  "${currentStoryboard.story?.length ?? 0} collection",
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ],
        ),
      );
    });
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
          heightFactor: MODAL_HEIGHT_LARGE_FACTOR,
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
