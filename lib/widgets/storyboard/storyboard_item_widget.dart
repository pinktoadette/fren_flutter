import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/machi/timeline_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/controller/timeline_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/date_format.dart';
import 'package:machi_app/helpers/text_link_preview.dart';
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
  TimelineController timelineController = Get.find(tag: 'timeline');

  late Storyboard storyboard;
  late AppLocalizations _i18n;
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
    _i18n = AppLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;
    double storyCoverWidth = width;
    double padding = 15;
    String title = storyboard.title;
    String photoUrl = storyboard.photoUrl ?? "";
    String subtitle =
        storyboard.story!.isNotEmpty ? storyboard.story![0].summary! : "";

    if (storyboard.story!.length == 1) {
      title = storyboard.story![0].title;
      photoUrl = storyboard.story![0].photoUrl ?? "";
    }
    // double rightBox = width - (storyCoverWidth + playWidth + padding * 3.2);
    String timestampLabel = storyboard.status == StoryStatus.PUBLISHED
        ? "Published on "
        : "Last Updated ";
    bool hasSeries = storyboard.story != null && storyboard.story!.length > 1;
    return Card(
        elevation: 1,
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(top: padding),
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
                child: Container(
                    padding: EdgeInsets.only(left: padding),
                    width: width - padding * 3.2,
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
                        textLinkPreview(context: context, text: subtitle)
                      ],
                    ))),
            if (photoUrl != "")
              InkWell(
                  onTap: () async {
                    _onStoryClick();
                  },
                  child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: StoryCover(
                          width: storyCoverWidth,
                          height: storyCoverWidth * 0.5,
                          photoUrl: photoUrl,
                          title: title))),
            if (hasSeries) const Divider(),
            if (hasSeries)
              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    ...storyboard.story!.asMap().entries.take(8).map((ele) {
                      return InkWell(
                          onTap: () {
                            storyboardController.setCurrentBoard(storyboard);
                            timelineController
                                .setStoryTimelineControllerCurrent(ele.value);
                            Get.to(() => StoryPageView(story: ele.value));
                          },
                          child: Padding(
                              padding:
                                  EdgeInsets.only(left: ele.key == 0 ? 15 : 5),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Collection ${ele.key + 1}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                    ),
                                    Text(
                                      ele.value.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium,
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            StoryCover(
                                              icon: ele.value.status ==
                                                      StoryStatus.UNPUBLISHED
                                                  ? const Icon(
                                                      Iconsax.lock,
                                                      size: 16,
                                                    )
                                                  : null,
                                              width: width * 0.3,
                                              height: width * 0.3,
                                              radius: 5,
                                              photoUrl:
                                                  ele.value.photoUrl ?? "",
                                              title: ele.value.title,
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                            width: width * 0.6,
                                            height: width * 0.3,
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Text(
                                                ele.value.pages?[0].scripts?[0]
                                                        .text ??
                                                    "",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                                overflow: TextOverflow.fade,
                                              ),
                                            )),
                                      ],
                                    ),
                                    SizedBox(
                                      width: width * 0.9,
                                      child: Align(
                                        alignment: Alignment.bottomRight,
                                        child: _likeItemWidget(ele.value),
                                      ),
                                    )
                                  ])));
                    }),
                  ])),
            if (hasSeries == false) _likeItemWidget(storyboard.story![0])
          ],
        ));
  }

  Future<void> _onStoryClick() async {
    /// if there is only one story, then go to the story bits
    /// if theres more than one, then show entire collection
    /// @todo if it has a collection index, then go to that index
    storyboardController.setCurrentBoard(storyboard);
    if (widget.message != null) {
      Get.to(() => StoriesView(message: widget.message!));
    } else {
      if ((storyboard.story!.isNotEmpty) & (storyboard.story!.length == 1)) {
        timelineController
            .setStoryTimelineControllerCurrent(storyboard.story![0]);
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

  /// likes should be on timeline. You dont like your own stuff
  Future<void> _onLikePressed(Story item, bool value) async {
    storyboardController.setCurrentBoard(storyboard);

    String response = await _timelineApi.likeStoryMachi(
        "story", item.storyId, value == true ? 1 : 0);
    if (response == "OK") {
      Story update = item.copyWith(
          mylikes: value == true ? 1 : 0,
          likes: value == true ? (item.likes! + 1) : (item.likes! - 1));
      timelineController.updateStoryboard(
          storyboard: storyboard, updateStory: update);
    }
  }

  Widget _likeItemWidget(Story item) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 10, right: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (item.status == StoryStatus.PUBLISHED)
              SizedBox(
                  height: 25,
                  child: Text(
                      "${item.commentCount ?? 0} ${_i18n.translate("comments")}",
                      style: Theme.of(context).textTheme.labelSmall)),
            SizedBox(
                width: 50,
                child: LikeItemWidget(
                    onLike: (val) {
                      _onLikePressed(item, val);
                    },
                    likes: item.likes ?? 0,
                    mylikes: item.mylikes ?? 0))
          ],
        ));
  }
}
