import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/api/machi/timeline_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/comment_controller.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/controller/timeline_controller.dart';
import 'package:machi_app/controller/user_controller.dart';
import 'package:machi_app/datas/script.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/date_format.dart';
import 'package:machi_app/helpers/image_cache_wrapper.dart';
import 'package:machi_app/helpers/navigation_helper.dart';
import 'package:machi_app/helpers/text_link_preview.dart';
import 'package:machi_app/helpers/truncate_text.dart';
import 'package:machi_app/screens/storyboard/page_view.dart';
import 'package:machi_app/widgets/like_widget.dart';
import 'package:machi_app/screens/storyboard/story_view.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:machi_app/widgets/story_cover.dart';
import 'package:machi_app/widgets/storyboard/my_edit/layout_edit.dart';
import 'package:machi_app/widgets/timeline/timeline_header.dart';

// StoryboardItemWidget -> StoriesView (List of stories / Add ) -> StoryItemWidget -> PageView
class StoryboardItemWidget extends StatefulWidget {
  final Storyboard item;
  final types.Message? message;
  final bool? hideCollection;
  final bool? showHeader;
  const StoryboardItemWidget(
      {Key? key,
      required this.item,
      this.message,
      this.hideCollection = false,
      this.showHeader = true})
      : super(key: key);

  @override
  _StoryboardItemWidgettState createState() => _StoryboardItemWidgettState();
}

class _StoryboardItemWidgettState extends State<StoryboardItemWidget> {
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  TimelineController timelineController = Get.find(tag: 'timeline');
  UserController userController = Get.find(tag: 'user');

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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    width = MediaQuery.of(context).size.width;
    double padding = 15;

    String timestampLabel = storyboard.status == StoryStatus.PUBLISHED
        ? "Published on "
        : "Last Updated ";
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
              showName: true,
              showMenu: false,
              underNameRow:
                  Text("$timestampLabel ${formatDate(storyboard.updatedAt)}",
                      style: const TextStyle(
                        fontSize: 12,
                      )),
            ),
          ),
        _displayType(storyboard, padding, width),
        if (widget.hideCollection == false) ..._showCollectionFooter()
      ],
    );
  }

  Widget _displayType(Storyboard storyboard, double padding, double width) {
    String title = storyboard.title;
    String photoUrl = storyboard.photoUrl ?? "";
    String subtitle =
        storyboard.story!.isNotEmpty && storyboard.story!.length == 1
            ? storyboard.story![0].summary!
            : "";
    if (storyboard.story!.isNotEmpty && storyboard.story!.length == 1) {
      StoryPages? page;
      try {
        page = storyboard.story?[0].pages?.firstWhere(
          (element) => element.scripts?.first.type == "text",
        );
      } catch (e) {
        // Handle the case when no element satisfies the condition
        page = null;
      }

      if (page != null) {
        subtitle = truncateText(maxLength: 200, text: page.scripts![0].text!);
      }
    }

    if (storyboard.story!.length == 1) {
      title = storyboard.story![0].title;
      photoUrl = storyboard.story![0].photoUrl ?? "";
    }

    if (storyboard.story![0].layout == Layout.COMIC) {
      /// @todo need to create a common meme layout. See under page_view _displayScript.
      int index = 0;
      Story story = storyboard.story![0];
      double w = width - padding * 2;
      String displayText = truncateScriptsTo250Chars(
          scripts: story.pages![0].scripts, length: 300);
      Script? firstScriptWithImage = story.pages![0].scripts!.firstWhere(
        (script) => script.type == 'image',
        orElse: () => Script(image: null),
      );
      return InkWell(
          onTap: () async {
            _navigateNextPage();
          },
          child: Container(
              margin: const EdgeInsets.only(top: 10),
              width: w,
              height: w,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      colorFilter: ColorFilter.mode(
                          const Color.fromARGB(255, 0, 0, 0).withOpacity(
                              story.pages![index].backgroundAlpha ?? 0.5),
                          BlendMode.darken),
                      image: story.pages![index].backgroundImageUrl != null
                          ? imageCacheWrapper(
                              story.pages![index].backgroundImageUrl!,
                            )
                          : story.pages![index].backgroundImageUrl != null
                              ? imageCacheWrapper(
                                  story.pages![index].backgroundImageUrl!)
                              : Image.asset(
                                  "assets/images/blank.png",
                                  scale: 0.2,
                                  width: 100,
                                ).image,
                      fit: BoxFit.cover)),
              child: displayText != ""
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: textLinkPreview(
                        useBorder: story.layout == Layout.COMIC,
                        context: context,
                        text: displayText,
                        maxLines: 9,
                        style: const TextStyle(color: Colors.black),
                      ))
                  : firstScriptWithImage.image != null
                      ? StoryCover(
                          photoUrl: firstScriptWithImage.image!.uri, title: "")
                      : const SizedBox.shrink()));
    }
    return InkWell(
        onTap: () async {
          _navigateNextPage();
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          width: width - padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (photoUrl != "")
                    StoryCover(
                        width: width * 0.4 - padding * 4,
                        height: width * 0.4 - padding * 4,
                        photoUrl: photoUrl,
                        title: title),
                  Container(
                      padding: EdgeInsets.only(left: photoUrl != "" ? 10 : 0),
                      width: width * 0.6 - (photoUrl != "" ? padding * 2 : 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(storyboard.category,
                              style: const TextStyle(
                                  fontSize: 14, color: APP_MUTED_COLOR)),
                        ],
                      )),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              if (subtitle != "")
                textLinkPreview(context: context, text: subtitle)
            ],
          ),
        ));
  }

  List<Widget> _showCollectionFooter() {
    bool hasSeries = storyboard.story != null && storyboard.story!.length > 1;
    return [
      if (hasSeries && userController.user != null)
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
                return SizedBox(
                    width: width,
                    child: _collectionCards(
                        index: index, story: storyboard.story![index]));
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
                    color: Colors.grey)))
      else
        _likeItemWidget(storyboard.story![0], false),
      const SizedBox(
        height: 20,
      )
    ];
  }

  Widget _collectionCards({required index, required Story story}) {
    return InkWell(
        onTap: () {
          storyboardController.setCurrentBoard(storyboard);
          timelineController.setStoryTimelineControllerCurrent(story);
          storyboardController.onGoToPageView(story);
          Get.to(() => StoryPageView(story: story));
        },
        child: Container(
            decoration: story.photoUrl != null && story.photoUrl != ""
                ? BoxDecoration(
                    image: DecorationImage(
                      image: imageCacheWrapper(story.photoUrl!),
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.topCenter,
                      colorFilter: ColorFilter.mode(
                          const Color.fromARGB(255, 32, 32, 32)
                              .withOpacity(0.9),
                          BlendMode.darken),
                    ),
                  )
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    shape: BoxShape.rectangle,
                    border:
                        Border.all(width: 1, color: APP_INVERSE_PRIMARY_COLOR)),
            padding: const EdgeInsets.all(15),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                width: width * 0.9,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: _likeItemWidget(story, true),
                ),
              )
            ])));
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
