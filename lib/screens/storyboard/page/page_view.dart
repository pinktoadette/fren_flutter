import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:iconsax/iconsax.dart';
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
import 'package:machi_app/helpers/theme_helper.dart';
import 'package:machi_app/helpers/truncate_text.dart';
import 'package:machi_app/screens/storyboard/confirm_publish.dart';
import 'package:machi_app/screens/storyboard/page/page_comment.dart';
import 'package:machi_app/screens/storyboard/page/page_info.dart';
import 'package:machi_app/widgets/ads/inline_ads.dart';
import 'package:machi_app/widgets/common/chat_bubble_container.dart';
import 'package:machi_app/widgets/report_list.dart';
import 'package:machi_app/widgets/story_cover.dart';
import 'package:machi_app/widgets/storyboard/my_edit/layout_edit.dart';
import 'package:machi_app/widgets/storyboard/my_edit/page_caption.dart';
import 'package:machi_app/widgets/storyboard/story/add_new_story.dart';
import 'package:machi_app/widgets/common/no_data.dart';
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
  /// Gets the current story in storyboard controller.
  StoryboardController storyboardController = Get.find(tag: 'storyboard');

  /// Updates likes and comment counts in timeline controller.
  TimelineController timelineController = Get.find(tag: 'timeline');

  /// Comment pagination on scroll.
  final controller = PageController(viewportFraction: 1, keepPage: true);

  /// language localization.
  late AppLocalizations _i18n;

  /// Use to determine if user scrolled the content and if next page should be scroll to or continue on current page scroll.
  bool _userScrolledAgain = false;

  /// Tracks how user scrolls the page. This is in conjunction with _userScrolledAgain.
  Timer? _scrollTimer;

  /// Current story.
  Story? story;

  /// Textcolor is determined by the theme of the app.
  late Color textColor;
  var pages = [];

  @override
  void initState() {
    super.initState();
    bool isDarkMode = ThemeHelper().isDark;
    textColor = isDarkMode ? Colors.white54 : Colors.black;

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

  /// Sets the timeline of the story. Use to update comment counts and likes.
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _i18n = AppLocalizations.of(context);
  }

  @override
  Widget build(BuildContext context) {
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
              backgroundColor: Colors.white24,
              title: Container(
                padding: const EdgeInsets.only(
                  top: 20,
                ),
                child: StoryHeaderWidget(story: story!),
              ),
              leading: BackButton(
                color: textColor,
                onPressed: () {
                  if (widget.isPreview == false) {
                    CommentController commentController =
                        Get.find(tag: 'comment');
                    commentController.clearComments();
                  }
                  Get.back();
                },
              ),
              leadingWidth: 50,
              actions: [
                if (widget.isPreview == false)
                  _unpublishedTools()
                else
                  Container(
                      padding: const EdgeInsets.only(top: 15.0, right: 10),
                      child: TextButton(
                          onPressed: () {
                            Get.to(() => ConfirmPublishDetails(
                                  story: widget.story,
                                ));
                          },
                          child: Text(
                            _i18n.translate("next_step"),
                            style: TextStyle(color: textColor),
                          ))),
                if (story?.status.name == StoryStatus.PUBLISHED.name)
                  PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: APP_INVERSE_PRIMARY_COLOR,
                      ),
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
              const PageCommentSheet()
          ]);
        }));
  }

  /// Report the content of the story.
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

  /// Displays the structure scaffold of the story.
  Widget _showPageWidget(BoxConstraints constraints) {
    Size size = MediaQuery.of(context).size;
    double height = size.height;

    if (story!.pages!.isEmpty) {
      return SizedBox(
          height: height,
          width: size.width,
          child: NoData(
            text: _i18n.translate("creative_mix_bits"),
            svgName: "error",
          ));
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
              bool hasBackground = !isEmptyString(backgroundUrl);
              double alphaValue =
                  hasBackground ? story?.pages![index].backgroundAlpha ?? 0 : 0;
              if (backgroundUrl != "") {
                Image.network(backgroundUrl);
              }

              /// Caption Mode
              if (story!.layout == Layout.CAPTION) {
                return Container(
                    height: size.height - 100,
                    margin: const EdgeInsets.only(bottom: 0),
                    decoration: _boxDecoration(
                        backgroundUrl: backgroundUrl, alphaValue: alphaValue),
                    child: Stack(
                      children: [
                        Positioned(
                            bottom: 120,
                            child: PageTextCaption(
                                script: story!.pages![index].scripts![0]))
                      ],
                    ));
              }

              return Container(
                height: size.height - 100,
                margin: const EdgeInsets.only(bottom: 0),
                decoration: _boxDecoration(
                    backgroundUrl: backgroundUrl, alphaValue: alphaValue),
                padding: const EdgeInsets.only(left: 40, top: 20, right: 20),
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
                              height: 110,
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
                                    _displayScript(
                                        script, size, backgroundUrl != ""),
                                    if (story!.layout == Layout.CONVO)
                                      Text(script.characterName ?? ""),
                                  ]);
                            }).toList())),
                            if (((index + 1) == story!.pages!.length) &
                                (story!.status == StoryStatus.PUBLISHED))
                              const Align(
                                alignment: Alignment.bottomCenter,
                                child: InlineAdaptiveAds(
                                  height: 50,
                                ),
                              ),
                            const SizedBox(
                              height: 210,
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
          top: size.height / 3,
          child: SizedBox(
            height: 50,
            width: size.width,
            child: SmoothPageIndicator(
              controller: controller,
              count: story!.pages!.length,
              axisDirection: Axis.vertical,
              effect: const ExpandingDotsEffect(
                  dotHeight: 5, dotWidth: 5, activeDotColor: APP_ACCENT_COLOR),
            ),
          )),

      /// creator of content and stats
      if (story!.status == StoryStatus.PUBLISHED)
        const Positioned(
          bottom: 0,
          right: 0,
          child: StoryPageInfoWidget(),
        )
    ]);
  }

  /// Displays how the content should be layed out.
  Widget _displayScript(Script script, Size size, bool hasBackground) {
    /// @todo need to create a common layout. See under storyboard_item_widget the display creates two separate layouts.
    /// edit_page_reorder also shares same logic
    Widget widget = const SizedBox.shrink();

    /// Other Modes
    switch (script.type) {
      case "text":
        widget = Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: textLinkPreview(
                useBorder: hasBackground && story!.layout != Layout.CONVO,
                width: story!.layout != Layout.CONVO ? size.width : null,
                text: script.text ?? "",
                textAlign: script.textAlign ?? TextAlign.left,
                style: TextStyle(
                    color: story!.layout == Layout.CONVO ? Colors.black : null,
                    fontSize: story!.layout != Layout.COMIC ? 16 : 20)));
        break;
      case "image":
        AspectRatioImage adjImage = AspectRatioImage(
            imageWidth: script.image!.width.toDouble(),
            imageHeight: script.image!.height.toDouble(),
            imageUrl: script.image!.uri);
        AspectRatioImage modifiedImage = adjImage.displayScript(size);

        widget = Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: StoryCover(
              photoUrl: modifiedImage.imageUrl,
              title: story?.title ?? "machi",
              width: modifiedImage.imageWidth,
              height: modifiedImage.imageHeight,
            ));
        break;
      default:
        break;
    }

    Widget widgetScript = story!.layout == Layout.CONVO
        ? StoryBubble(
            isRight: story!.createdBy.userId == script.characterId,
            widget: widget,
            size: size)
        : widget;
    return widgetScript;
  }

  /// Shows action tools when story status is not published.
  Widget _unpublishedTools() {
    Storyboard storyboard = storyboardController.currentStoryboard;
    bool isDarkMode = ThemeHelper().isDark;
    Color color = isDarkMode == true ? APP_INVERSE_PRIMARY_COLOR : Colors.black;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if ((story?.status != StoryStatus.PUBLISHED) &
            (storyboard.story!.length == 1))
          IconButton(
            onPressed: () {
              Get.to(() => const AddNewStory());
            },
            icon: Icon(
              Iconsax.add,
              color: color,
            ),
          ),
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
              icon: Icon(
                Iconsax.edit,
                size: 20,
                color: color,
              ))
      ],
    );
  }

  BoxDecoration _boxDecoration(
      {required String backgroundUrl, required double alphaValue}) {
    return BoxDecoration(
        image: DecorationImage(
            colorFilter: ColorFilter.mode(
                const Color.fromARGB(255, 0, 0, 0).withOpacity(alphaValue),
                BlendMode.darken),
            image: backgroundUrl != ""
                ? ImageCacheWrapper(backgroundUrl)
                : Image.asset(
                    "assets/images/blank.png",
                    scale: 0.2,
                    width: 100,
                  ).image,
            fit: BoxFit.cover));
  }
}
