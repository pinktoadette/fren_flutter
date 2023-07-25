import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/rendering.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/machi/interactive_api.dart';
import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/api/machi/timeline_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/comment_controller.dart';
import 'package:machi_app/controller/interactive_board_controller.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/controller/timeline_controller.dart';
import 'package:machi_app/datas/interactive.dart';
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
class InteractivePageView extends StatefulWidget {
  final InteractiveBoard interactive;
  const InteractivePageView({Key? key, required this.interactive})
      : super(key: key);

  @override
  _InteractivePageViewState createState() => _InteractivePageViewState();
}

class _InteractivePageViewState extends State<InteractivePageView> {
  TimelineController timelineController = Get.find(tag: 'timeline');
  CommentController commentController = Get.find(tag: 'comment');
  InteractiveBoardController interactiveController =
      Get.find(tag: 'interactive');

  final controller = PageController(viewportFraction: 1, keepPage: true);
  final _timelineApi = TimelineApi();
  final _interaciveApi = InteractiveBoardApi();
  late AppLocalizations _i18n;
  double bodyHeightPercent = 0.85;
  double headerHeight = 140;
  final ScrollController _scrollController = ScrollController();
  double _previousScrollOffset = 0.0;

  late InteractiveBoardPrompt prompts;
  var pages = [];

  @override
  void initState() {
    super.initState();
    _getInitialPath();
    _scrollController.addListener(_onScroll);
  }

  void dispose() {
    _scrollController
        .dispose(); // Dispose the ScrollController to avoid memory leaks
    super.dispose();
  }

  void _getInitialPath() async {
    InteractiveBoardPrompt p =
        await _interaciveApi.getInteractiveId(widget.interactive.interactiveId);
    setState(() {
      prompts = p;
    });
  }

  void _onScroll() {
    double currentScrollOffset = _scrollController.offset;
    ScrollDirection scrollDirection;

    if (currentScrollOffset > _previousScrollOffset) {
      scrollDirection = ScrollDirection.forward;
    } else {
      scrollDirection = ScrollDirection.reverse;
    }

    // You can use the `scrollDirection` variable to determine the direction of the scroll
    print('Scroll Direction: $scrollDirection');

    _previousScrollOffset = currentScrollOffset;
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    if (pages.isEmpty) {
      return Scaffold(
          appBar: AppBar(
            title: Text(_i18n.translate("story_collection")),
          ),
          body: NoData(text: _i18n.translate("loading")));
    }
    return Scaffold(
        appBar: AppBar(
            centerTitle: false,
            title: Text(
              widget.interactive.category,
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
            ]),
        body: Stack(children: [
          SingleChildScrollView(
              child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _showPageWidget(),
                    ],
                  ))),
          _commentSheet()
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
              itemId: widget.interactive.interactiveId,
              itemType: "interactive",
            ));
      },
    );
  }

  Future<void> _onLikePressed(Story item, bool value) async {
    try {} catch (err, s) {
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );

      await FirebaseCrashlytics.instance.recordError(err, s,
          reason: 'Cannot like interactive item', fatal: true);
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

  Widget _showPageWidget() {
    Size size = MediaQuery.of(context).size;
    double height = size.height * bodyHeightPercent;

    return WillPopScope(
        onWillPop: () async {
          // Disable swipe back to previous page
          return false;
        },
        child: Stack(alignment: Alignment.topCenter, children: [
          SizedBox(
            height: height - 80,
            width: double.infinity,
            child: PageView.builder(
              scrollDirection: Axis.vertical, // First, scroll vertically
              itemCount: 3, // Number of pages in the vertical direction
              itemBuilder: (context, verticalIndex) {
                return PageView.builder(
                  scrollDirection: Axis.horizontal, // Then, scroll horizontally
                  itemCount: 3, // Number of pages in the horizontal direction
                  itemBuilder: (context, horizontalIndex) {
                    return Container(
                      color: Colors.primaries[
                          (verticalIndex + horizontalIndex) %
                              Colors.primaries.length],
                      child: Center(
                        child: Text(
                            'Page ${verticalIndex * 3 + horizontalIndex + 1}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Positioned(
              bottom: 30,
              width: size.width,
              child: SizedBox(
                  height: 50,
                  width: size.width,
                  child: const Icon(Icons.swipe))),
          Positioned(
            bottom: 30,
            right: 10,
            child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Obx(
                  () => LikeItemWidget(
                      onLike: (val) {
                        // _onLikePressed(widget.interactive, val);
                      },
                      size: 20,
                      likes: timelineController.currentStory.likes ?? 0,
                      mylikes: timelineController.currentStory.mylikes ?? 0),
                )),
          )
        ]));
  }
}
