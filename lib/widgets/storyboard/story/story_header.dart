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
class StoryHeaderWidget extends StatefulWidget {
  final Story story;
  const StoryHeaderWidget({Key? key, required this.story}) : super(key: key);
  @override
  _StoryHeaderWidgetState createState() => _StoryHeaderWidgetState();
}

class _StoryHeaderWidgetState extends State<StoryHeaderWidget> {
  late Story thisStory;

  @override
  void initState() {
    super.initState();
    setState(() {
      thisStory = widget.story;
    });
  }

  @override
  Widget build(BuildContext context) {
    double storyCoverWidth = 50;
    double padding = 0;
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  StoryCover(
                      width: storyCoverWidth,
                      height: storyCoverWidth,
                      photoUrl: thisStory.photoUrl ?? "",
                      title: thisStory.title),
                  const SizedBox(width: 10),
                  Flexible(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TimelineHeader(
                        paddingLeft: 0,
                        user: thisStory.createdBy,
                        showAvatar: false,
                        showName: true,
                        fontSize: 12,
                        isChild: true,
                      ),
                      Text(thisStory.title,
                          overflow: TextOverflow.fade,
                          maxLines: 2,
                          softWrap: false,
                          style: Theme.of(context).textTheme.labelMedium),
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
              heightFactor: MODAL_HEIGHT_LARGE_FACTOR,
              child: DraggableScrollableSheet(
                snap: true,
                initialChildSize: 1,
                minChildSize: 0.9,
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
