import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/api/machi/timeline_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/comment_controller.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/script.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/helpers/text_link_preview.dart';
import 'package:machi_app/widgets/like_widget.dart';
import 'package:machi_app/widgets/report_list.dart';
import 'package:machi_app/widgets/storyboard/story/add_new_story.dart';
import 'package:machi_app/widgets/comment/post_comment_widget.dart';
import 'package:machi_app/widgets/common/no_data.dart';
import 'package:machi_app/widgets/image/image_rounded.dart';
import 'package:machi_app/widgets/comment/comment_widget.dart';
import 'package:machi_app/widgets/storyboard/my_edit/edit_story.dart';
import 'package:machi_app/widgets/storyboard/publish_story.dart';
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
  final controller = PageController(viewportFraction: 1, keepPage: true);
  final _timelineApi = TimelineApi();

  late AppLocalizations _i18n;
  double bodyHeightPercent = 0.825;
  double headerHeight = 140;
  final _storyApi = StoryApi();

  Story? story;
  var pages = [];

  @override
  void initState() {
    Get.lazyPut<CommentController>(() => CommentController(), tag: "comment");

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

      storyboardController.setCurrentStory(details);
      setState(() {
        story = details;
      });
    } catch (error) {
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_ERROR,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    if (story == null && pages.isEmpty) {
      return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.isPreview == true
                  ? _i18n.translate("storyboard_preview")
                  : _i18n.translate("story_collection"),
              style: Theme.of(context).textTheme.bodySmall,
            ),
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
              commentController.clearReplyTo();
              Get.back();
            },
          ),
          actions: [
            if (widget.isPreview == false) _unpublishedTools(),
            if (widget.isPreview == true)
              Container(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                      onPressed: () {
                        Get.to(() => PublishStory(story: story!));
                      },
                      child: Text(_i18n.translate("publish")))),
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
              StoryHeaderWidget(story: story!),
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
            heightFactor: 0.9,
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
            likes: value == true ? (item.likes! + 1) : (item.likes! - 1));
        storyboardController.updateStory(story: update);
      }
    } catch (err) {
      Get.snackbar(
        _i18n.translate("DELETE"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_ERROR,
      );
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
                          color: Theme.of(context).colorScheme.background,
                          child: Stack(children: [
                            CustomScrollView(
                                controller: scrollController,
                                slivers: [
                                  SliverToBoxAdapter(
                                      child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, top: 10),
                                    child: Text(_i18n.translate("comments"),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall),
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
        ? size.height * bodyHeightPercent - headerHeight
        : size.height - headerHeight - 10;
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

    return Stack(alignment: Alignment.bottomCenter, children: [
      SizedBox(
          height: height,
          width: size.width,
          child: PageView.builder(
            controller: controller,
            itemCount: story!.pages!.length,
            itemBuilder: (_, index) {
              List<Script>? scripts = story!.pages![index].scripts;
              return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Card(
                      child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: scripts!.map((script) {
                          if (script.type == "text") {
                            return textLinkPreview(context, script.text ?? "");
                          } else if (script.type == "image") {
                            return RoundedImage(
                              width: 516,
                              height: 516,
                              photoUrl: script.image?.uri ?? "",
                              icon: const Icon(Iconsax.image),
                            );
                          }
                          return const SizedBox.shrink();
                        }).toList()),
                  )));
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
                          dotHeight: 8,
                          dotWidth: 14,
                          activeDotColor: APP_ACCENT_COLOR),
                    )),
                const SizedBox(
                  width: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: LikeItemWidget(
                      onLike: (val) {
                        _onLikePressed(widget.story, val);
                      },
                      size: 20,
                      likes: widget.story.likes ?? 0,
                      mylikes: widget.story.mylikes ?? 0),
                ),
              ],
            ),
          ))
    ]);
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
