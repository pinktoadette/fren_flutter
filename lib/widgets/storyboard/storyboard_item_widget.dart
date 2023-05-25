import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
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
    return Card(
        elevation: 1,
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            InkWell(
                onTap: () async {
                  _onStoryClick();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: EdgeInsets.all(padding),
                        child: StoryCover(
                            width: storyCoverWidth,
                            photoUrl: storyboard.photoUrl,
                            title: storyboard.title)),
                    SizedBox(
                        width: width -
                            (storyCoverWidth + playWidth + padding * 3.2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 15,
                            ),
                            Text(
                                "${storyboard.status.name} ${formatDate(storyboard.updatedAt)}",
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
                              storyboard.summary ?? "No summary",
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.fade,
                            ),
                          ],
                        ))
                  ],
                )),
            Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TimelineHeader(user: storyboard.createdBy),
                    TextButton.icon(
                      onPressed: null,
                      icon: const Icon(Iconsax.menu_1, size: 16),
                      label: Text("${storyboard.story?.length} collection",
                          style: const TextStyle(fontSize: 12)),
                    ),
                    TextButton.icon(
                      onPressed: null,
                      icon: const Icon(Iconsax.message_text_1, size: 16),
                      label: Text("${storyboard.story?.length} comment",
                          style: const TextStyle(fontSize: 12)),
                    ),
                    LikeItemWidget(
                        onLike: (val) {
                          _onLikePressed(widget.item, val);
                        },
                        likes: storyboard.likes ?? 0,
                        mylikes: storyboard.mylikes ?? 0)
                  ],
                ))
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
