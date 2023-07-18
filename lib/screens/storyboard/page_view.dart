import 'dart:math';

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
import 'package:machi_app/widgets/common/chat_bubble_container.dart';
import 'package:machi_app/widgets/like_widget.dart';
import 'package:machi_app/widgets/report_list.dart';
import 'package:machi_app/widgets/storyboard/my_edit/layout_edit.dart';
import 'package:machi_app/widgets/storyboard/story/add_new_story.dart';
import 'package:machi_app/widgets/comment/post_comment_widget.dart';
import 'package:machi_app/widgets/common/no_data.dart';
import 'package:machi_app/widgets/image/image_rounded.dart';
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
    Get.lazyPut<CommentController>(() => CommentController(), tag: "comment");

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
          title: Text(
            widget.isPreview == true
                ? _i18n.translate("storyboard_preview")
                : story?.title ?? "",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          leading: BackButton(
            onPressed: () {
              CommentController commentController = Get.find(tag: 'comment');
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
        body: Stack(children: [
          SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _showPageWidget(),
            ],
          )),
          if (story?.status.name == StoryStatus.PUBLISHED.name) _commentSheet()
        ]));
  }

  void _onReport() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
            heightFactor: 0.85,
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

      await FirebaseCrashlytics.instance
          .recordError(err, s, reason: 'Cannot like item', fatal: true);
    }
  }

  Widget _commentSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 1 - bodyHeightPercent,
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
                                        left: 20, top: 10),
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
                            Positioned(bottom: 0, child: PostCommentWidget())
                          ]))));
            });
      },
    );
  }

  Widget _showPageWidget() {
    Size size = MediaQuery.of(context).size;
    double height = story?.status.name == StoryStatus.PUBLISHED.name
        ? size.height * bodyHeightPercent
        : size.height - 100;

    if (story!.pages!.isEmpty) {
      return SizedBox(
          height: height,
          width: size.width,
          child: PageView.builder(
              controller: controller,
              itemCount: 1,
              itemBuilder: (_, index) {
                return NoData(text: _i18n.translate("storybits_empty"));
              }));
    }

    return Stack(alignment: Alignment.topCenter, children: [
      SizedBox(
          height: height - 80,
          width: size.width,
          child: PageView.builder(
            controller: controller,
            itemCount: story!.pages!.length,
            itemBuilder: (_, index) {
              List<Script>? scripts = story!.pages![index].scripts;
              return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      StoryHeaderWidget(story: story!),
                      Card(
                          child: Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                colorFilter: ColorFilter.mode(
                                    const Color.fromARGB(255, 0, 0, 0)
                                        .withOpacity(0.6),
                                    BlendMode.darken),
                                image: story?.pages![index]
                                            .backgroundImageUrl !=
                                        null
                                    ? NetworkImage(story!
                                        .pages![index].backgroundImageUrl!)
                                    : story!.pages![index].backgroundImageUrl !=
                                            null
                                        ? NetworkImage(story!
                                            .pages![index].backgroundImageUrl!)
                                        : Image.asset(
                                            "assets/images/blank.jpg",
                                            scale: 0.2,
                                            width: 100,
                                          ).image,
                                fit: BoxFit.cover)),
                        width: size.width,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                            crossAxisAlignment: story!.layout == Layout.CONVO
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: scripts!.map((script) {
                              CrossAxisAlignment alignment =
                                  story!.layout == Layout.CONVO
                                      ? story!.createdBy.username.trim() ==
                                              script.characterName!.trim()
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
                                    const SizedBox(
                                      height: 20,
                                    )
                                  ]);
                            }).toList()),
                      ))
                    ],
                  ));
            },
          )),
      Positioned(
          bottom: 0,
          child: SizedBox(
            height: 50,
            width: size.width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Spacer(),
                Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SmoothPageIndicator(
                      controller: controller,
                      count: story!.pages!.length,
                      effect: const ExpandingDotsEffect(
                          dotHeight: 10,
                          dotWidth: 18,
                          activeDotColor: APP_ACCENT_COLOR),
                    )),
                const SizedBox(
                  width: 20,
                ),
                Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Obx(
                      () => LikeItemWidget(
                          onLike: (val) {
                            _onLikePressed(widget.story, val);
                          },
                          size: 20,
                          likes: timelineController.currentStory.likes ?? 0,
                          mylikes:
                              timelineController.currentStory.mylikes ?? 0),
                    )),
              ],
            ),
          ))
    ]);
  }

  Widget _displayScript(Script script, Size size) {
    Widget widget = const SizedBox.shrink();
    if (script.type == "text") {
      widget = textLinkPreview(
          useBorder: story!.layout == Layout.PUBLICATION,
          context: context,
          text: script.text ?? "",
          style: TextStyle(
              color: story!.layout == Layout.CONVO
                  ? Colors.black
                  : Theme.of(context).colorScheme.primary));
    } else if (script.type == "image") {
      widget = RoundedImage(
        width: size.width * 0.9,
        height: size.width * 0.9,
        photoUrl: script.image?.uri ?? "",
        icon: const Icon(Iconsax.image),
      );
    }
    Widget widgetScript = story!.layout == Layout.CONVO
        ? StoryBubble(
            isRight: story!.createdBy.username == script.characterName,
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
