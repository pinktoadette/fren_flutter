import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/widgets/storyboard/story/story_edit.dart';
import 'package:machi_app/widgets/storyboard/story/story_info.dart';

// Story book Onboarding swipe -> child : story_widget
class StoryHeaderWidget extends StatefulWidget {
  final Story story;
  final double? width;
  const StoryHeaderWidget({Key? key, required this.story, this.width})
      : super(key: key);
  @override
  State<StoryHeaderWidget> createState() => _StoryHeaderWidgetState();
}

class _StoryHeaderWidgetState extends State<StoryHeaderWidget> {
  late Story thisStory;
  Color textColor = APP_INVERSE_PRIMARY_COLOR;

  @override
  void initState() {
    super.initState();
    setState(() {
      thisStory = widget.story;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double padding = 0;
    double width = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () async {
        _showEditStory(context);
      },
      child: Container(
          padding: EdgeInsets.only(left: padding, bottom: 5, right: padding),
          width: widget.width ?? width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                thisStory.createdBy.username,
                style: TextStyle(color: textColor, fontSize: 14),
              ),
              Text(
                thisStory.title,
                overflow: TextOverflow.fade,
                maxLines: 2,
                softWrap: false,
                style: TextStyle(color: textColor, fontSize: 16),
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
              heightFactor: MODAL_HEIGHT_SMALL_FACTOR,
              child: DraggableScrollableSheet(
                snap: true,
                initialChildSize: 1,
                minChildSize: MODAL_HEIGHT_SMALL_FACTOR,
                builder: (context, scrollController) => SingleChildScrollView(
                    controller: scrollController,
                    child: showInfo == false
                        ? StoryEdit(
                            onUpdateStory: (story) => setState(() {
                              thisStory = story;
                            }),
                          )
                        : const StoryInfo()),
              ),
            ));
  }
}
