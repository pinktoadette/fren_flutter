import 'package:flutter/material.dart';
import 'package:machi_app/api/machi/timeline_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/date_format.dart';
import 'package:machi_app/screens/storyboard/page_view.dart';
import 'package:machi_app/widgets/like_widget.dart';
import 'package:machi_app/widgets/story_cover.dart';
import 'package:machi_app/screens/storyboard/story_view.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:machi_app/widgets/timeline/timeline_header.dart';

// StoryboardItemWidget -> StoriesView (List of stories / Add ) -> StoryItemWidget -> PageView
class StoryboardItemWidget extends StatefulWidget {
  final Storyboard item;
  final types.Message? message;
  const StoryboardItemWidget({Key? key, required this.item, this.message})
      : super(key: key);

  @override
  _StoryboardItemWidgettState createState() => _StoryboardItemWidgettState();
}

class _StoryboardItemWidgettState extends State<StoryboardItemWidget> {
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  late Storyboard storyboard;
  final _timelineApi = TimelineApi();

  @override
  void initState() {
    super.initState();
    setState(() {
      storyboard = widget.item;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double storyCoverWidth = 80;
    double padding = 15;
    double playWidth =
        storyboard.status == StoryStatus.PUBLISHED ? PLAY_BUTTON_WIDTH : 0;
    String title = storyboard.title;
    String photoUrl = storyboard.photoUrl ?? "";
    String subtitle =
        storyboard.story!.isNotEmpty ? storyboard.story![0].summary! : "";

    if (storyboard.story!.length == 1) {
      title = storyboard.story![0].title;
      photoUrl = storyboard.story![0].photoUrl ?? "";
    }
    double rightBox = width - (storyCoverWidth + playWidth + padding * 3.2);
    String timestampLabel = storyboard.status == StoryStatus.PUBLISHED
        ? "Published on "
        : "Last Updated ";
    return Card(
        elevation: 1,
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(left: padding, top: padding),
              width: width,
              child: TimelineHeader(
                user: storyboard.createdBy,
                showName: true,
                showMenu: false,
              ),
            ),
            InkWell(
                onTap: () async {
                  _onStoryClick();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (photoUrl != "")
                      Padding(
                          padding: EdgeInsets.all(padding),
                          child: StoryCover(
                              width: storyCoverWidth,
                              photoUrl: photoUrl,
                              title: title)),
                    Container(
                        padding: photoUrl == ""
                            ? EdgeInsets.only(left: padding)
                            : const EdgeInsets.only(left: 0),
                        width:
                            photoUrl != "" ? rightBox : width - padding * 3.2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 15,
                            ),
                            Text(
                                "$timestampLabel ${formatDate(storyboard.updatedAt)}",
                                style: const TextStyle(fontSize: 10)),
                            Text(storyboard.category,
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: APP_SECONDARY_ACCENT_COLOR,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(
                                child: Text(
                              storyboard.title,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold),
                            )),
                            Text(
                              subtitle,
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.fade,
                            ),
                          ],
                        ))
                  ],
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    width: width - 10,
                    padding: EdgeInsets.only(left: 20, bottom: padding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (storyboard.story != null &&
                            storyboard.story!.length > 1)
                          ...storyboard.story!.take(10).map((sto) {
                            return Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: StoryCover(
                                    width: 30,
                                    height: 30,
                                    radius: 5,
                                    photoUrl: sto.photoUrl ?? "",
                                    title: sto.title));
                          }),
                        const Spacer(),
                        SizedBox(
                            width: 50,
                            child: LikeItemWidget(
                                onLike: (val) {
                                  _onLikePressed(widget.item, val);
                                },
                                likes: storyboard.likes ?? 0,
                                mylikes: storyboard.mylikes ?? 0))
                      ],
                    ))
              ],
            )
          ],
        ));
  }

  Future<void> _onStoryClick() async {
    /// if there is only one story, then go to the story bits
    /// if theres more than one, then show entire collection
    /// @todo if it has a collection index, then go to that index
    storyboardController.setCurrentBoard(widget.item);
    if (widget.message != null) {
      Get.to(() => StoriesView(message: widget.message!));
    } else {
      if ((storyboard.story!.isNotEmpty) & (storyboard.story!.length == 1)) {
        storyboardController.setCurrentStory(storyboard.story![0]);
        Get.to(() => StoryPageView(story: storyboard.story![0]));
      } else {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const StoriesView(),
          ),
        ).then((_) {
          setState(() {
            storyboard = storyboardController.currentStoryboard;
          });
        });
      }
    }
  }

  Future<void> _onLikePressed(Storyboard item, bool value) async {
    String response = await _timelineApi.likeStoryMachi(
        "storyboard", item.storyboardId, value == true ? 1 : 0);
    if (response == "OK") {
      Storyboard update = item.copyWith(
          mylikes: value == true ? 1 : 0,
          likes: value == true ? (item.likes! + 1) : (item.likes! - 1));
      storyboardController.updateStoryboard(update);
    }
  }
}
