import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/api/machi/timeline_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/comment_controller.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/controller/timeline_controller.dart';
import 'package:machi_app/datas/script.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/helpers/text_link_preview.dart';
import 'package:machi_app/screens/storyboard/confirm_publish.dart';
import 'package:machi_app/widgets/ads/inline_ads.dart';
import 'package:machi_app/widgets/common/avatar_initials.dart';
import 'package:machi_app/widgets/common/chat_bubble_container.dart';
import 'package:machi_app/widgets/like_widget.dart';
import 'package:machi_app/widgets/report_list.dart';
import 'package:machi_app/widgets/story_cover.dart';
import 'package:machi_app/widgets/storyboard/my_edit/layout_edit.dart';
import 'package:machi_app/widgets/storyboard/my_edit/page_direction_edit.dart';
import 'package:machi_app/widgets/storyboard/story/add_new_story.dart';
import 'package:machi_app/widgets/comment/post_comment_widget.dart';
import 'package:machi_app/widgets/common/no_data.dart';
import 'package:machi_app/widgets/comment/comment_widget.dart';
import 'package:machi_app/widgets/storyboard/my_edit/edit_story.dart';
import 'package:machi_app/widgets/storyboard/story/story_header.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// Need to call pages since storyboard
/// did not query this in order to increase speed
class StoryPageView extends StatefulWidget {
  final Story story;
  final bool? isPreview;
  const StoryPageView({Key? key, required this.story, this.isPreview = false})
      : super(key: key);

  @override
  _StoryPageViewState createState() => _StoryPageViewState();
}

class _StoryPageViewState extends State<StoryPageView> {
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  TimelineController timelineController = Get.find(tag: 'timeline');
  CommentController commentController = Get.find(tag: 'comment');

  final controller = PageController(viewportFraction: 1, keepPage: true);
  final _timelineApi = TimelineApi();

  late AppLocalizations _i18n;
  double bodyHeightPercent = 0.85;
  double headerHeight = 140;
  final _storyApi = StoryApi();

  Story? story;
  var pages = [];

  @override
  void initState() {
    super.initState();

    if (widget.isPreview == true) {
      setState(() {
        story = widget.story;
      });
    } else {
      getStoryContent();
    }
  }

  void getStoryContent() async {
    try {
      Story details = await _storyApi.getMyStories(widget.story.storyId);
      timelineController.setStoryTimelineControllerCurrent(details);
      setState(() {
        story = details;
      });
    } catch (err, s) {
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
      await FirebaseCrashlytics.instance.recordError(err, s,
          reason:
              'Cannot get story content: storyId ${story?.storyId ?? "Unknown id"}',
          fatal: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    if (story == null && pages.isEmpty) {
      return Scaffold(
          appBar: AppBar(
            title: Text(widget.isPreview == true
                ? _i18n.translate("storyboard_preview")
                : _i18n.translate("story_collection")),
          ),
          body: NoData(text: _i18n.translate("loading")));
    }
    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            widget.isPreview == true
                ? _i18n.translate("storyboard_preview")
                : story?.title ?? "",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          leading: BackButton(
            onPressed: () {
              commentController.clearComments();
              Get.back();
            },
          ),
          titleSpacing: 0,
          actions: [
            if (widget.isPreview == false) _unpublishedTools(),
            if (widget.isPreview == true)
              Container(
                  padding: const EdgeInsets.all(10.0),
                  child: OutlinedButton(
                      onPressed: () {
                        Get.to(() => ConfirmPublishDetails(
                              story: widget.story,
                            ));
                      },
                      child: Text(_i18n.translate("publish_preview")))),
            if (story?.status.name == StoryStatus.PUBLISHED.name)
              PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem(
                          child: Text('Report'),
                          value: 'report',
                        )
                      ],
                  onSelected: (val) {
                    switch (val) {
                      case 'report':
                        _onReport();
                        break;
                      default:
                        break;
                    }
                  })
          ],
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          return Stack(children: [
            SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _showPageWidget(constraints),
              ],
            )),
            if (story?.status.name == StoryStatus.PUBLISHED.name)
              _commentSheet()
          ]);
        }));
  }

  void _onReport() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
            heightFactor: MODAL_HEIGHT_LARGE_FACTOR,
            child: ReportForm(
              itemId: story!.storyId,
              itemType: "story",
            ));
      },
    );
  }

  Future<void> _onLikePressed(Story item, bool value) async {
    try {
      String response = await _timelineApi.likeStoryMachi(
          "story", item.storyId, value == true ? 1 : 0);
      if (response == "OK") {
        Story update = item.copyWith(
            mylikes: value == true ? 1 : 0,
            likes:
                value == true ? (item.likes! + 1) : max(0, (item.likes! - 1)));
        timelineController.updateStoryboard(
            storyboard: storyboardController.currentStoryboard,
            updateStory: update);
      }
    } catch (err, s) {
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );

      await FirebaseCrashlytics.instance.recordError(err, s,
          reason: 'Cannot like storyboard item', fatal: true);
    }
  }

  Widget _commentSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 1 - bodyHeightPercent + 0.025,
      minChildSize: 1 - bodyHeightPercent,
      expand: true,
      builder: (BuildContext context, ScrollController scrollController) {
        if (controller.hasClients) {}
        return AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .tertiary
                              .withOpacity(0.5)
                              .withAlpha(50),
                          blurRadius: 15,
                          offset: const Offset(0, -10)),
                    ],
                  ),
                  child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24)),
                      child: Container(
                          color: const Color.fromARGB(255, 20, 20, 20),
                          child: Stack(children: [
                            CustomScrollView(
                                controller: scrollController,
                                slivers: [
                                  SliverToBoxAdapter(
                                      child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, top: 10, bottom: 10),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.keyboard_double_arrow_up,
                                          size: 14,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(_i18n.translate("comments"),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall)
                                      ],
                                    ),
                                  )),
                                  const CommentWidget(),
                                  const SliverToBoxAdapter(
                                      child: SizedBox(
                                    height: 100,
                                  ))
                                ]),
                            const Positioned(
                                bottom: 0, child: PostCommentWidget())
                          ]))));
            });
      },
    );
  }

  Widget _showPageWidget(BoxConstraints constraints) {
    Size size = MediaQuery.of(context).size;
    double footerHeight = 100;
    double height = story?.status.name == StoryStatus.PUBLISHED.name
        ? size.height * bodyHeightPercent
        : size.height - footerHeight;

    if (story!.pages!.isEmpty) {
      return SizedBox(
          height: height,
          width: size.width,
          child: NoData(text: _i18n.translate("storybits_empty")));
    }
    return Stack(alignment: Alignment.topCenter, children: [
      SizedBox(
          height: height - footerHeight,
          width: constraints.maxWidth,
          child: PageView.builder(
            controller: controller,
            scrollDirection: story!.pageDirection == PageDirection.HORIZONTAL
                ? Axis.horizontal
                : Axis.vertical,
            itemCount: storyboardController.currentStory.pages!.length,
            itemBuilder: (_, index) {
              List<Script>? scripts = story!.pages![index].scripts;
              String? background = story?.pages?[index].backgroundImageUrl;

              String backgroundUrl =
                  (background != null && background.contains("http"))
                      ? background
                      : "";

              return Card(
                child: Container(
                  height: size.height - 250,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          colorFilter: ColorFilter.mode(
                              const Color.fromARGB(255, 0, 0, 0).withOpacity(
                                  story?.pages![index].backgroundAlpha ?? 0.5),
                              BlendMode.darken),
                          image: backgroundUrl != ""
                              ? CachedNetworkImageProvider(
                                  backgroundUrl,
                                  errorListener: () => const Icon(Icons.error),
                                )
                              : Image.asset(
                                  "assets/images/blank.jpg",
                                  scale: 0.2,
                                  width: 100,
                                ).image,
                          fit: BoxFit.cover)),
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                        constraints: BoxConstraints(
                            minWidth: constraints.maxWidth * 0.7,
                            minHeight: constraints.maxHeight - 200),
                        child: IntrinsicHeight(
                            child: Column(
                                crossAxisAlignment:
                                    story!.layout == Layout.CONVO
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                children: [
                              Expanded(
                                  child: Column(
                                      children: scripts!.map((script) {
                                CrossAxisAlignment alignment =
                                    story!.layout == Layout.CONVO
                                        ? story!.createdBy.userId ==
                                                script.characterId
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start
                                        : script.type == 'image'
                                            ? CrossAxisAlignment.center
                                            : CrossAxisAlignment.start;
                                return Column(
                                    crossAxisAlignment: alignment,
                                    children: [
                                      _displayScript(script, size),
                                      if (story!.layout == Layout.CONVO)
                                        Text(script.characterName ?? ""),
                                    ]);
                              }).toList())),
                              if (((index + 1) % 2 == 0) &
                                  (story!.status == StoryStatus.PUBLISHED))
                                const Align(
                                  alignment: Alignment.bottomCenter,
                                  child: InlineAdaptiveAds(
                                    height: 50,
                                  ),
                                ),
                              const SizedBox(
                                height: 50,
                              )
                            ]))),
                  ),
                ),
              );
            },
          )),
      Positioned(
          bottom: story!.pageDirection == PageDirection.HORIZONTAL
              ? 50
              : size.height / 2,
          width: story!.pageDirection == PageDirection.HORIZONTAL
              ? size.width
              : 40,
          left: story!.pageDirection == PageDirection.HORIZONTAL ? 0 : 10,
          child: SizedBox(
            height: 50,
            width: size.width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SmoothPageIndicator(
                      controller: controller,
                      count: story!.pages!.length,
                      axisDirection:
                          story!.pageDirection == PageDirection.HORIZONTAL
                              ? Axis.horizontal
                              : Axis.vertical,
                      effect: const ExpandingDotsEffect(
                          dotHeight: 10,
                          dotWidth: 18,
                          activeDotColor: APP_ACCENT_COLOR),
                    )),
              ],
            ),
          )),
      if (story!.status == StoryStatus.PUBLISHED)
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
              color: Colors.black.withOpacity(0.8),
              child: Obx(
                () => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: AvatarInitials(
                            radius: 16,
                            userId: story!.createdBy.userId,
                            photoUrl: story!.createdBy.photoUrl,
                            username: story!.createdBy.username)),
                    Container(
                        padding: const EdgeInsets.only(left: 0),
                        child: LikeItemWidget(
                            onLike: (val) {
                              _onLikePressed(widget.story, val);
                            },
                            size: 40,
                            likes: timelineController.currentStory.likes ?? 0,
                            mylikes:
                                timelineController.currentStory.mylikes ?? 0)),
                    Container(
                        padding: const EdgeInsets.only(left: 30, top: 12),
                        width: size.width,
                        child: Row(
                          children: [
                            const Icon(
                              Iconsax.message,
                              size: 16,
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(
                              timelineController.currentStory.commentCount
                                  .toString(),
                              style: const TextStyle(fontSize: 12),
                            )
                          ],
                        ))
                  ],
                ),
              )),
        )
    ]);
  }

  Widget _displayScript(Script script, Size size) {
    /// @todo need to create a common meme layout. See under storyboard_item_widget the display creates two separate layouts.

    Widget widget = const SizedBox.shrink();
    if (script.type == "text") {
      widget = textLinkPreview(
          useBorder: story!.layout == Layout.COMIC,
          context: context,
          width: story!.layout != Layout.CONVO ? size.width : null,
          text: script.text ?? "",
          textAlign: script.textAlign ?? TextAlign.left,
          style: TextStyle(
              color: story!.layout == Layout.CONVO
                  ? Colors.black
                  : Theme.of(context).colorScheme.primary));
    } else if (script.type == "image") {
      widget = Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: StoryCover(
            photoUrl: script.image?.uri ?? "",
            title: story?.title ?? "machi",
            width: size.width * 0.9,
            height: size.width * 0.9,
          ));
    }
    Widget widgetScript = story!.layout == Layout.CONVO
        ? StoryBubble(
            isRight: story!.createdBy.userId == script.characterId,
            widget: widget,
            size: size)
        : widget;
    return widgetScript;
  }

  Widget _unpublishedTools() {
    Storyboard storyboard = storyboardController.currentStoryboard;
    return Row(
      children: [
        if ((story?.status != StoryStatus.PUBLISHED) &
            (storyboard.story!.length == 1))
          TextButton.icon(
              onPressed: () {
                Get.to(() => const AddNewStory());
              },
              icon: const Icon(Iconsax.add),
              label: Text(
                _i18n.translate("story_collection"),
                style: Theme.of(context).textTheme.labelSmall,
              )),
        if (story?.status != StoryStatus.PUBLISHED)
          IconButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPage(
                      passStory: story ?? widget.story,
                    ),
                  ),
                ).then((val) {
                  setState(() {
                    story = val;
                  });
                });
              },
              icon: const Icon(
                Iconsax.edit,
                size: 20,
              ))
      ],
    );
  }
}
