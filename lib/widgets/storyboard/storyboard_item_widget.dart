import 'dart:math';

import 'package:flutter/material.dart';
import 'package:machi_app/api/machi/timeline_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/comment_controller.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/controller/timeline_controller.dart';
import 'package:machi_app/controller/user_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/date_format.dart';
import 'package:machi_app/helpers/image_cache_wrapper.dart';
import 'package:machi_app/helpers/navigation_helper.dart';
import 'package:machi_app/helpers/text_link_preview.dart';
import 'package:machi_app/helpers/truncate_text.dart';
import 'package:machi_app/screens/storyboard/page/page_view.dart';
import 'package:machi_app/widgets/like_widget.dart';
import 'package:machi_app/screens/storyboard/story_view.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:machi_app/widgets/story_cover.dart';
import 'package:machi_app/widgets/timeline/timeline_header.dart';

// StoryboardItemWidget -> StoriesView (List of stories / Add ) -> StoryItemWidget -> PageView
class StoryboardItemWidget extends StatefulWidget {
  final Storyboard item;
  final types.Message? message;
  final bool? hideCollection;
  final bool? showHeader;
  final bool? showName;
  final bool? showAvatar;
  const StoryboardItemWidget(
      {Key? key,
      required this.item,
      this.message,
      this.hideCollection = false,
      this.showHeader = true,
      this.showAvatar = true,
      this.showName = true})
      : super(key: key);

  @override
  State<StoryboardItemWidget> createState() => _StoryboardItemWidgettState();
}

class _StoryboardItemWidgettState extends State<StoryboardItemWidget> {
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  TimelineController timelineController = Get.find(tag: 'timeline');
  UserController userController = Get.find(tag: 'user');

  late Storyboard storyboard;
  late AppLocalizations _i18n;
  final _timelineApi = TimelineApi();
  double padding = 15;
  late String timestampLabel;

  @override
  void initState() {
    super.initState();
    setState(() {
      storyboard = widget.item;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _i18n = AppLocalizations.of(context);
    timestampLabel = storyboard.status == StoryStatus.PUBLISHED
        ? _i18n.translate("post_published_on")
        : _i18n.translate("post_last_updated");
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      double width = MediaQuery.of(context).size.width;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.showHeader == true)
            Container(
              padding: EdgeInsets.only(top: padding, bottom: padding),
              width: width,
              child: TimelineHeader(
                radius: 24,
                user: storyboard.createdBy,
                showName: widget.showName,
                showAvatar: widget.showAvatar,
                showMenu: false,
                underNameRow:
                    Text("$timestampLabel ${formatDate(storyboard.updatedAt)}",
                        style: const TextStyle(
                          fontSize: 12,
                        )),
              ),
            ),
          _buildDefaultLayout(
            storyboard,
            padding,
            width,
          ),
          if (widget.hideCollection == false)
            Row(children: _showCollectionFooter())
        ],
      );
    });
  }

  Widget _buildDefaultLayout(
    Storyboard storyboard,
    double padding,
    double width,
  ) {
    /// if there is only one story, display first cover
    /// if there are many stories, display storyboard cover
    final firstStory = storyboard.story!.first;
    String? photoUrl = !isEmptyString(firstStory.photoUrl)
        ? firstStory.photoUrl
        : firstStory.pages?.isNotEmpty == true
            ? firstStory.pages![0].thumbnail
            : null;

    String title = storyboard.title;
    String subtitle = storyboard.summary ?? "";
    String category = storyboard.category;
    if (storyboard.story!.length == 1) {
      title = firstStory.title;
      subtitle = truncateText(
        maxLength: 140,
        text: firstStory.summary ?? "",
      );
      category = firstStory.category;
    }

    if (photoUrl == null) {
      return InkWell(
          onTap: _navigateNextPage,
          child: _textDisplay(
              title: title,
              category: category,
              subtitle: subtitle,
              photoUrl: photoUrl ?? "",
              padding: padding,
              width: width));
    }

    return InkWell(
      onTap: _navigateNextPage,
      child: Stack(
        children: [
          // Main Container with Background Image
          Container(
              width: width,
              height: width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: ImageCacheWrapper(photoUrl),
                  fit: BoxFit.cover,
                ),
              )),
          // Dark Overlay Footer with Content
          Positioned(
            bottom: 0,
            child: Container(
              color: Colors.black.withOpacity(0.6),
              width: width,
              height: min(260, width * 0.45),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _textDisplay(
                      title: title,
                      category: category,
                      subtitle: subtitle,
                      photoUrl: photoUrl,
                      padding: padding,
                      width: width)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textDisplay(
      {required String title,
      required String subtitle,
      required String category,
      required String photoUrl,
      required double padding,
      required double width}) {
    Color textColor = photoUrl == ""
        ? Theme.of(context).colorScheme.primary
        : APP_INVERSE_PRIMARY_COLOR;
    return Container(
        padding: const EdgeInsets.all(20),
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(color: textColor),
            ),
            Text(
              category,
              style: const TextStyle(fontSize: 14, color: APP_MUTED_COLOR),
            ),
            textLinkPreview(
                text: subtitle,
                style: TextStyle(fontSize: 14, color: textColor)),
          ],
        ));
  }

  List<Widget> _showCollectionFooter() {
    bool hasSeries = storyboard.story != null && storyboard.story!.length > 1;
    return [
      if (hasSeries && userController.user != null)
        ...storyboard.story!.take(4).map((s) {
          String thumbnail = s.pages
                  ?.firstWhere(
                    (element) => element.thumbnail != "",
                  )
                  .thumbnail ??
              "";

          return InkWell(
            onTap: () {
              storyboardController.setCurrentBoard(storyboard);
              timelineController.setStoryTimelineControllerCurrent(s);
              storyboardController.onGoToPageView(s);
              Get.to(() => StoryPageView(story: s));
            },
            child: StoryCover(
                height: 80,
                width: 80,
                radius: 0,
                photoUrl: thumbnail,
                title: s.title),
          );
        })
      else
        _likeItemWidget(storyboard.story![0], false),
      const SizedBox(
        height: 20,
      )
    ];
  }

  Future<void> _navigateNextPage() async {
    NavigationHelper.handleGoToPageOrLogin(
      context: context,
      userController: userController,
      navigateAction: () {
        _onStoryClick();
      },
    );
  }

  Future<void> _onStoryClick() async {
    /// if there is only one story, then go to the story bits
    /// if theres more than one, then show entire collection
    storyboardController.setCurrentBoard(storyboard);
    if (widget.message != null) {
      Get.to(() => StoriesView(message: widget.message!));
    } else {
      Get.lazyPut<CommentController>(() => CommentController(), tag: "comment");

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

  Widget _likeItemWidget(Story item, bool removeLeftPadding) {
    return InkWell(
      onTap: () async {
        _navigateNextPage();
      },
      child: Padding(
          padding: EdgeInsets.only(
              left: removeLeftPadding == true ? 0 : 15, bottom: 0, right: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                  width: 50,
                  child: LikeItemWidget(
                      onLike: (val) {
                        _onLikePressed(item, val);
                      },
                      likes: item.likes ?? 0,
                      mylikes: item.mylikes ?? 0)),
              Container(
                height: 35,
                padding: const EdgeInsets.only(left: 5, right: 10),
                child: const Text("•"),
              ),
              SizedBox(
                  height: 30,
                  child: Text(
                      "${_i18n.translate("replies")}  ${item.commentCount ?? 0} ",
                      style: const TextStyle(fontSize: 14))),
            ],
          )),
    );
  }
}
