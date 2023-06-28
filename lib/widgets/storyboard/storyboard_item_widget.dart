import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/api/machi/timeline_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/controller/timeline_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/date_format.dart';
import 'package:machi_app/helpers/text_link_preview.dart';
import 'package:machi_app/helpers/truncate_text.dart';
import 'package:machi_app/screens/storyboard/page_view.dart';
import 'package:machi_app/widgets/like_widget.dart';
import 'package:machi_app/screens/storyboard/story_view.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:machi_app/widgets/timeline/timeline_header.dart';

// StoryboardItemWidget -> StoriesView (List of stories / Add ) -> StoryItemWidget -> PageView
class StoryboardItemWidget extends StatefulWidget {
  final Storyboard item;
  final types.Message? message;
  final bool? hideCollection;
  const StoryboardItemWidget(
      {Key? key, required this.item, this.message, this.hideCollection = false})
      : super(key: key);

  @override
  _StoryboardItemWidgettState createState() => _StoryboardItemWidgettState();
}

class _StoryboardItemWidgettState extends State<StoryboardItemWidget> {
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  TimelineController timelineController = Get.find(tag: 'timeline');

  late Storyboard storyboard;
  late AppLocalizations _i18n;
  late double width;
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
    width = MediaQuery.of(context).size.width;
    double padding = 15;
    String title = storyboard.title;
    String photoUrl = storyboard.photoUrl ?? "";
    String subtitle =
        storyboard.story!.isNotEmpty && storyboard.story!.length == 1
            ? storyboard.story![0].summary!
            : "";
    if (storyboard.story!.isNotEmpty && storyboard.story!.length == 1) {
      var page = storyboard.story![0].pages!
          .firstWhereOrNull((element) => element.scripts!.first.type == "text");
      if (page != null) {
        subtitle = truncateText(maxLength: 250, text: page.scripts![0].text!);
      }
    }

    if (storyboard.story!.length == 1) {
      title = storyboard.story![0].title;
      photoUrl = storyboard.story![0].photoUrl ?? "";
    }
    // double rightBox = width - (storyCoverWidth + playWidth + padding * 3.2);
    String timestampLabel = storyboard.status == StoryStatus.PUBLISHED
        ? "Published on "
        : "Last Updated ";

    return Card(
        child: Container(
            decoration: photoUrl != ""
                ? BoxDecoration(
                    image: DecorationImage(
                      opacity: 0.15,
                      image: NetworkImage(
                        photoUrl,
                      ),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  )
                : const BoxDecoration(color: Colors.transparent),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(top: padding),
                  width: width,
                  child: TimelineHeader(
                    radius: 24,
                    user: storyboard.createdBy,
                    showName: true,
                    showMenu: false,
                    underNameRow: Text(
                        "$timestampLabel ${formatDate(storyboard.updatedAt)}",
                        style: const TextStyle(
                          fontSize: 12,
                        )),
                  ),
                ),
                InkWell(
                    onTap: () async {
                      _onStoryClick();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      width: width - padding * 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              child: Text(
                            storyboard.title,
                            style: Theme.of(context).textTheme.headlineSmall,
                          )),
                          Text(storyboard.category,
                              style: const TextStyle(
                                  fontSize: 14, color: APP_MUTED_COLOR)),
                          const SizedBox(
                            height: 15,
                          ),
                          if (subtitle != "")
                            textLinkPreview(context: context, text: subtitle)
                        ],
                      ),
                    )),
                if (widget.hideCollection == false) ..._showCollectionFooter()
              ],
            )));
  }

  List<Widget> _showCollectionFooter() {
    bool hasSeries = storyboard.story != null && storyboard.story!.length > 1;
    return [
      if (hasSeries)
        Swiper(
            itemWidth: width,
            itemHeight: 250,
            layout: SwiperLayout.TINDER,
            fade: 0.8,
            viewportFraction: 0.7,
            scale: 0.8,
            itemCount: storyboard.story!.length,
            itemBuilder: (context, index) {
              if (storyboard.story![index].status == StoryStatus.PUBLISHED) {
                return _collectionCards(
                    index: index, story: storyboard.story![index]);
              }
              return const SizedBox.shrink();
            },
            outer: false,
            indicatorLayout: PageIndicatorLayout.COLOR,
            autoplay: false,
            pagination: const SwiperPagination(
                alignment: Alignment.bottomCenter,
                builder: DotSwiperPaginationBuilder(
                    size: 5,
                    space: 3,
                    activeColor: APP_ACCENT_COLOR,
                    color: Colors.grey))),
      if (hasSeries == false) _likeItemWidget(storyboard.story![0])
    ];
  }

  Widget _collectionCards({required index, required Story story}) {
    return InkWell(
        onTap: () {
          storyboardController.setCurrentBoard(storyboard);
          timelineController.setStoryTimelineControllerCurrent(story);
          Get.to(() => StoryPageView(story: story));
        },
        child: Card(
            child: Container(
                decoration: story.photoUrl != null && story.photoUrl != ""
                    ? BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(story.photoUrl!),
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.topCenter,
                          colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.9), BlendMode.darken),
                        ),
                      )
                    : const BoxDecoration(shape: BoxShape.rectangle),
                padding: const EdgeInsets.all(15),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Collection ${index + 1}",
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      Text(
                        story.title,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      SizedBox(
                          width: width - 40,
                          height: width * 0.3,
                          child: Padding(
                            padding: const EdgeInsets.all(0),
                            child: Text(
                              story.pages?[0].scripts?[0].text ?? "",
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.fade,
                            ),
                          )),
                      SizedBox(
                        width: width * 0.9,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: _likeItemWidget(story),
                        ),
                      )
                    ]))));
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
        padding: const EdgeInsets.only(bottom: 0, right: 10),
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
