import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/rendering.dart';
import 'package:machi_app/api/machi/interactive_api.dart';
import 'package:machi_app/api/machi/timeline_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/comment_controller.dart';
import 'package:machi_app/controller/interactive_board_controller.dart';
import 'package:machi_app/controller/timeline_controller.dart';
import 'package:machi_app/datas/interactive.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/widgets/animations/loader.dart';
import 'package:machi_app/widgets/button/loading_button.dart';
import 'package:machi_app/widgets/common/no_data.dart';
import 'package:machi_app/widgets/like_widget.dart';
import 'package:machi_app/widgets/report_list.dart';
import 'package:machi_app/widgets/comment/post_comment_widget.dart';
import 'package:machi_app/widgets/comment/comment_widget.dart';

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
  final PageController _pageController = PageController();

  final controller = PageController(viewportFraction: 1, keepPage: true);
  final _timelineApi = TimelineApi();
  final _interaciveApi = InteractiveBoardApi();
  late AppLocalizations _i18n;
  double bodyHeightPercent = 0.85;
  double headerHeight = 140;
  List<String> _selectedChoices = [];
  String? _currentSelection;
  InteractiveBoardPrompt? prompt;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getInitialPath();
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    return Scaffold(
        appBar: AppBar(
            centerTitle: false,
            title: Text(
              _i18n.translate("interactive"),
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
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _showPageWidget(),
            ],
          )),
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

  Future<void> _onLikePressed(InteractiveBoard item, bool value) async {
    try {
      String response = await _timelineApi.likeStoryMachi(
          "interactive", item.interactiveId, value == true ? 1 : 0);
      if (response == "OK") {}
    } catch (err, s) {
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

    if (prompt == null) {
      return Center(child: NoData(text: _i18n.translate("no_data")));
    }

    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Stack(alignment: Alignment.topCenter, children: [
          SizedBox(
            height: height - 80,
            width: double.infinity,
            child: PageView.builder(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: widget.interactive.sequence * 2,
              itemBuilder: (context, index) {
                if (index % 2 == 0) {
                  int adjustedIndex = index ~/ 2;
                  if (adjustedIndex < widget.interactive.sequence) {
                    // Show the regular content using the original PageView.builder
                    return PageView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 3,
                        itemBuilder: (context, horizontalIndex) {
                          return Card(
                              child: Container(
                                  padding: const EdgeInsets.all(20),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: Column(
                                      children: [
                                        widget.interactive.hidePrompt ==
                                                    false &&
                                                adjustedIndex == 0
                                            ? Text(widget.interactive.prompt)
                                            : const SizedBox.shrink(),
                                        Text(prompt!.mainText),
                                        isLoading
                                            ? const Frankloader()
                                            : const SizedBox(height: 20),
                                        if (prompt!.options.length >= 3)
                                          ...prompt!.options
                                              .asMap()
                                              .entries
                                              .map((option) {
                                            int idx = option.key;
                                            String choice = option.value;
                                            if (idx < 3) {
                                              return Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  width: size.width * 0.75,
                                                  child: OutlinedButton(
                                                      style: OutlinedButton.styleFrom(
                                                          side: BorderSide(
                                                              color: _currentSelection ==
                                                                      choice
                                                                  ? APP_ACCENT_COLOR
                                                                  : APP_MUTED_COLOR)),
                                                      onPressed: () {
                                                        setState(() {
                                                          _currentSelection =
                                                              choice;
                                                          if (_selectedChoices
                                                              .contains(
                                                                  choice)) {
                                                            _selectedChoices
                                                                .remove(choice);
                                                          } else {
                                                            _selectedChoices
                                                                .add(choice);
                                                          }
                                                        });
                                                        _getNextPath(
                                                          sequence: index,
                                                          choice: idx,
                                                        );
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10),
                                                        child: Text(choice
                                                                    .length >
                                                                3
                                                            ? choice
                                                                .substring(3)
                                                            : choice),
                                                      )));
                                            }
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10),
                                              child: Text(choice),
                                            );
                                          }),
                                      ],
                                    ),
                                  )));
                        });
                  }
                  return const SizedBox.shrink();
                }
                return Card(
                  color: Colors.white12,
                  child: Center(
                      child: Column(
                    children: [
                      loadingButton(size: 40),
                      const Text("An image is here")
                    ],
                  )),
                );
              },
            ),
          ),
          Positioned(
            bottom: 30,
            right: 10,
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: LikeItemWidget(
                  onLike: (val) {
                    _onLikePressed(widget.interactive, val);
                  },
                  size: 20,
                  likes: 0,
                  mylikes: 0),
            ),
          )
        ]));
  }

  void _getInitialPath() async {
    InteractiveBoardPrompt p =
        await _interaciveApi.getInteractiveId(widget.interactive.interactiveId);
    setState(() {
      prompt = p;
    });
  }

  void _getNextPath({required int choice, required int sequence}) async {
    // Step 1: Scroll to the right with a delay
    if (_pageController.page!.toInt() < widget.interactive.sequence * 2 - 1) {
      await Future.delayed(
          const Duration(milliseconds: 500)); // Add a delay of 500 milliseconds
      _pageController.nextPage(
        duration: const Duration(milliseconds: 1000),
        curve: Curves.ease,
      );
    }

    Map<String, dynamic> userResponse = {
      "option": choice + 1,
      "interactiveId": widget.interactive.interactiveId,
      "sequence": sequence + 1,
      "action":
          "Previous response: ${_selectedChoices.join('')}. ${prompt!.mainText}"
    };
    InteractiveBoardPrompt p =
        await _interaciveApi.getNextPath(userResponse: userResponse);

    // Step 2: Scroll down after the API call is complete
    if (_pageController.page!.toInt() < widget.interactive.sequence * 2 - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 1000),
        curve: Curves.ease,
      );
    }

    setState(() {
      prompt = p;
    });
  }
}
