import 'dart:async';
import 'dart:math';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
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
import 'package:machi_app/helpers/image_aspect_ratio.dart';
import 'package:machi_app/helpers/image_cache_wrapper.dart';
import 'package:machi_app/helpers/text_link_preview.dart';
import 'package:machi_app/screens/storyboard/confirm_publish.dart';
import 'package:machi_app/widgets/ads/inline_ads.dart';
import 'package:machi_app/widgets/common/avatar_initials.dart';
import 'package:machi_app/widgets/common/chat_bubble_container.dart';
import 'package:machi_app/widgets/like_widget.dart';
import 'package:machi_app/widgets/report_list.dart';
import 'package:machi_app/widgets/story_cover.dart';
import 'package:machi_app/widgets/storyboard/my_edit/layout_edit.dart';
import 'package:machi_app/widgets/storyboard/story/add_new_story.dart';
import 'package:machi_app/widgets/comment/post_comment_widget.dart';
import 'package:machi_app/widgets/common/no_data.dart';
import 'package:machi_app/widgets/comment/comment_widget.dart';
import 'package:machi_app/widgets/storyboard/my_edit/edit_story.dart';
import 'package:machi_app/widgets/storyboard/story/story_header.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class StoryPageView extends StatefulWidget {
  final Story story;
  final bool? isPreview;
  const StoryPageView({Key? key, required this.story, this.isPreview = false})
      : super(key: key);

  @override
  State<StoryPageView> createState() => _StoryPageViewState();
}

class _StoryPageViewState extends State<StoryPageView> {
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  TimelineController timelineController = Get.find(tag: 'timeline');

  final controller = PageController(viewportFraction: 1, keepPage: true);
  final _timelineApi = TimelineApi();
  // ignore: non_constant_identifier_names
  static double BODY_HEIGHT_PERCENT = 1;
  late AppLocalizations _i18n;
  double bodyHeightPercent = BODY_HEIGHT_PERCENT;
  double headerHeight = 0;

  bool _userScrolledAgain = false;
  Timer? _scrollTimer;

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

  @override
  void dispose() {
    super.dispose();
    _scrollTimer?.cancel();
    controller.dispose();
  }

  void getStoryContent() {
    if (!mounted) {
      return;
    }
    try {
      timelineController.setStoryTimelineControllerCurrent(widget.story);
      setState(() {
        story = widget.story;
      });
    } catch (err) {
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    if (story == null && pages.isEmpty) {
      return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(widget.isPreview == true
                ? _i18n.translate("creative_mix_preview")
                : _i18n.translate("creative_mix_collection")),
            backgroundColor: Colors.black12,
          ),
          body: NoData(text: _i18n.translate("loading")));
    }
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
            preferredSize:
                const Size.fromHeight(80), // Set the desired height here
            child: AppBar(
              centerTitle: false,
              backgroundColor: Colors.black26,
              title: Container(
                padding: const EdgeInsets.only(
                  top: 20,
                ),
                width: 200,
                child: StoryHeaderWidget(story: story!, width: 100),
              ),
              leading: BackButton(
                color: Colors.white54,
                onPressed: () {
                  if (widget.isPreview == false) {
                    CommentController commentController =
                        Get.find(tag: 'comment');
                    commentController.clearComments();
                  }
                  Get.back();
                },
              ),
              titleSpacing: 0,
              actions: [
                if (widget.isPreview == false)
                  _unpublishedTools()
                else
                  Container(
                      padding: const EdgeInsets.only(top: 15.0, right: 10),
                      child: OutlinedButton(
                          onPressed: () {
                            Get.to(() => ConfirmPublishDetails(
                                  story: widget.story,
                                ));
                          },
                          child: Text(
                            _i18n.translate("next_step"),
                            style: const TextStyle(color: Colors.white60),
                          ))),
                if (story?.status.name == StoryStatus.PUBLISHED.name)
                  PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem(
                              value: 'report',
                              child: Text('Report'),
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
            )),
        body: LayoutBuilder(builder: (context, constraints) {
          return Stack(children: [
            _showPageWidget(constraints),
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
          reason: 'Cannot like storyboard item', fatal: false);
    }
  }

  Widget _commentSheet() {
    return NotificationListener<DraggableScrollableNotification>(
        onNotification:
            (DraggableScrollableNotification scrollableNotification) {
          if (scrollableNotification.extent ==
              scrollableNotification.minExtent) {
            setState(() {
              bodyHeightPercent = BODY_HEIGHT_PERCENT;
            });
          }

          return false;
        },
        child: DraggableScrollableSheet(
          initialChildSize: 0.15,
          minChildSize: 0.15,
          maxChildSize: 0.9,
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
        ));
  }

  Widget _showPageWidget(BoxConstraints constraints) {
    Size size = MediaQuery.of(context).size;
    double height = size.height;

    if (story!.pages!.isEmpty) {
      return SizedBox(
          height: height,
          width: size.width,
          child: NoData(text: _i18n.translate("creative_mix_bits")));
    }
    return Stack(alignment: Alignment.topCenter, children: [
      NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            /// @todo duplicate function in edit_story.dart
            double currentPos = notification.metrics.pixels;
            double maxScrollExtent = notification.metrics.maxScrollExtent;
            final ScrollDirection direction = notification.direction;

            // Check if the user has reached the bottom of the page.
            if (currentPos == maxScrollExtent) {
              // Wait for 1 second to see if the user scrolls again.
              if (_scrollTimer != null &&
                  _scrollTimer!.isActive &&
                  (direction == ScrollDirection.reverse)) {
                // The user scrolled again within x seconds.
                _userScrolledAgain = true;
                controller.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeIn);
              } else {
                _scrollTimer?.cancel();
                _scrollTimer = Timer(const Duration(milliseconds: 2500), () {
                  if (_userScrolledAgain) {
                    _userScrolledAgain = false;
                  }
                });
              }
            }
            if (direction == ScrollDirection.forward && currentPos == 0) {
              controller.previousPage(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeIn,
              );
              // if comment is open, and user scrolls down, then collapse it.
              setState(() {
                bodyHeightPercent = BODY_HEIGHT_PERCENT;
              });
            } else {
              if (currentPos < 0 && direction == ScrollDirection.reverse) {
                controller.nextPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                );
              }
            }

            return false;
          },
          child: PageView.builder(
            controller: controller,
            scrollDirection: Axis.vertical,
            itemCount: storyboardController.currentStory.pages!.length,
            itemBuilder: (_, index) {
              List<Script>? scripts = story!.pages![index].scripts;
              String backgroundUrl =
                  story?.pages?[index].backgroundImageUrl ?? "";

              return Container(
                height: size.height,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        colorFilter: ColorFilter.mode(
                            const Color.fromARGB(255, 0, 0, 0).withOpacity(
                                story?.pages![index].backgroundAlpha ?? 0.5),
                            BlendMode.darken),
                        image: backgroundUrl != ""
                            ? ImageCacheWrapper(backgroundUrl)
                            : Image.asset(
                                "assets/images/blank.png",
                                scale: 0.2,
                                width: 100,
                              ).image,
                        fit: BoxFit.cover)),
                padding: const EdgeInsets.only(left: 40, top: 20, right: 40),
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                      constraints: BoxConstraints(
                          minWidth: constraints.maxWidth * 0.7,
                          minHeight: constraints.maxHeight - 200),
                      child: IntrinsicHeight(
                          child: Column(
                              crossAxisAlignment: story!.layout == Layout.CONVO
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                            const SizedBox(
                              height: 100,
                            ),
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
              );
            },
          )),

      /// Page indicator
      Positioned(
          left: 10,
          width: 10,
          top: size.height / 4,
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
                      axisDirection: Axis.vertical,
                      effect: const ExpandingDotsEffect(
                          dotHeight: 5,
                          dotWidth: 5,
                          activeDotColor: APP_ACCENT_COLOR),
                    )),
              ],
            ),
          )),

      /// creator of content and stats
      if (story!.status == StoryStatus.PUBLISHED)
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
              color: Colors.black.withOpacity(0.8),
              width: size.width,
              height: 180,
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: AvatarInitials(
                            radius: 16,
                            userId: story!.createdBy.userId,
                            photoUrl: story!.createdBy.photoUrl,
                            username: story!.createdBy.username)),
                    Container(
                        padding: const EdgeInsets.only(left: 0),
                        child: Obx(() => LikeItemWidget(
                            onLike: (val) {
                              _onLikePressed(widget.story, val);
                            },
                            size: 40,
                            likes: timelineController.currentStory.likes ?? 0,
                            mylikes:
                                timelineController.currentStory.mylikes ?? 0))),
                    Container(
                        padding: const EdgeInsets.only(left: 30, top: 12),
                        child: Row(
                          children: [
                            const Icon(
                              Iconsax.message,
                              size: 16,
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Obx(() => Text(
                                  timelineController.currentStory.commentCount
                                      .toString(),
                                  style: const TextStyle(fontSize: 12),
                                ))
                          ],
                        ))
                  ]),
                  Container(
                      padding: const EdgeInsets.only(right: 20),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => {_copyLink(context)},
                            icon: const Icon(Icons.share),
                            iconSize: 16,
                          ),
                        ],
                      ))
                ],
              )),
        )
    ]);
  }

  void _copyLink(BuildContext context) {
    String textToCopy =
        "${APP_WEBSITE}post/${story!.storyId.substring(0, 5)}-${story!.slug}";
    Clipboard.setData(ClipboardData(text: textToCopy));
    Get.snackbar(
      "Link",
      'Copied to clipboard: $textToCopy',
      snackPosition: SnackPosition.TOP,
      backgroundColor: APP_TERTIARY,
    );
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
      AspectRatioImage adjImage = AspectRatioImage(
          imageWidth: script.image!.width.toDouble(),
          imageHeight: script.image!.height.toDouble(),
          imageUrl: script.image!.uri);
      AspectRatioImage modifiedImage = adjImage.displayScript(size);

      widget = Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: StoryCover(
            photoUrl: modifiedImage.imageUrl,
            title: story?.title ?? "machi",
            width: modifiedImage.imageWidth,
            height: modifiedImage.imageHeight,
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if ((story?.status != StoryStatus.PUBLISHED) &
            (storyboard.story!.length == 1))
          TextButton.icon(
              onPressed: () {
                Get.to(() => const AddNewStory());
              },
              icon: const Icon(
                Iconsax.add,
                color: Colors.white60,
              ),
              label: Text(
                _i18n.translate("creative_mix_collection"),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white60,
                ),
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
                color: Colors.white60,
              ))
      ],
    );
  }
}
