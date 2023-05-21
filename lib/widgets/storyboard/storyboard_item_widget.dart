import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/machi/timeline_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/date_format.dart';
import 'package:machi_app/widgets/like_widget.dart';
import 'package:machi_app/widgets/story_cover.dart';
import 'package:machi_app/screens/storyboard/story_view.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:machi_app/widgets/timeline/timeline_header.dart';

// StoryboardItemWidget -> StoriesView (List of stories / Add ) -> StoryItemWidget -> PageView -> PageItemWidget
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

  late AppLocalizations _i18n;
  final _timelineApi = TimelineApi();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;
    double storyCoverWidth = 80;
    double padding = 15;
    double playWidth =
        widget.item.status == StoryStatus.PUBLISHED ? PLAY_BUTTON_WIDTH : 0;
    return Card(
        elevation: 1,
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: EdgeInsets.all(padding),
                    child: InkWell(
                        onTap: () async {
                          _onStoryClick();
                        },
                        child: StoryCover(
                            width: storyCoverWidth,
                            photoUrl: widget.item.photoUrl,
                            title: widget.item.title))),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () async {
                        _onStoryClick();
                      },
                      child: SizedBox(
                          width: width -
                              (storyCoverWidth + playWidth + padding * 3.2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "${widget.item.status.name} ${formatDate(widget.item.updatedAt)}",
                                  style: const TextStyle(fontSize: 10)),
                              Text(widget.item.category,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: APP_SECONDARY_ACCENT_COLOR,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(
                                  child: Text(
                                widget.item.title,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold),
                              )),
                              Text(
                                widget.item.summary ?? "No summary",
                                style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.fade,
                              ),
                            ],
                          )),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TimelineHeader(user: widget.item.createdBy),
                    TextButton.icon(
                      onPressed: null,
                      icon: const Icon(Iconsax.menu_1, size: 16),
                      label: Text("${widget.item.story?.length} collection",
                          style: const TextStyle(fontSize: 12)),
                    ),
                    TextButton.icon(
                      onPressed: null,
                      icon: const Icon(Iconsax.message_text_1, size: 16),
                      label: Text("${widget.item.story?.length} comment",
                          style: const TextStyle(fontSize: 12)),
                    ),
                    LikeItemWidget(
                        onLike: (val) {
                          _onLikePressed(widget.item, val);
                        },
                        likes: widget.item.likes ?? 0,
                        mylikes: widget.item.mylikes ?? 0)
                  ],
                ))
          ],
        ));
  }

  Future<void> _onStoryClick() async {
    storyboardController.currentStoryboard = widget.item;
    if (widget.message != null) {
      Get.to(() => StoriesView(message: widget.message!));
    } else {
      Get.to(() => const StoriesView());
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
