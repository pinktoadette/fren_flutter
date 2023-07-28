import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/machi/interactive_api.dart';
import 'package:machi_app/api/machi/timeline_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/comment_controller.dart';
import 'package:machi_app/controller/interactive_board_controller.dart';
import 'package:machi_app/controller/timeline_controller.dart';
import 'package:machi_app/datas/interactive.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/widgets/ads/inline_ads.dart';
import 'package:machi_app/widgets/ads/interstitial_ads.dart';
import 'package:machi_app/widgets/animations/loader.dart';
import 'package:machi_app/widgets/button/loading_button.dart';
import 'package:machi_app/widgets/common/no_data.dart';
import 'package:machi_app/widgets/divider_text.dart';
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
  final List<String> _selectedChoices = [];
  String? _currentSelection;
  int _currentSeq = 1;
  InteractiveBoardPrompt? prompt;
  bool isLoading = false;
  int _adTime = 8;

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
              IconButton(
                  onPressed: () {
                    AlertDialog(
                      title: Text(
                        _i18n.translate("Interactive"),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      content:
                          Text(_i18n.translate("interactive_mode_action_info")),
                      actions: <Widget>[
                        OutlinedButton(
                            onPressed: () => {
                                  Navigator.of(context).pop(false),
                                },
                            child: Text(_i18n.translate("OK"))),
                      ],
                    );
                  },
                  icon: const Icon(Iconsax.info_circle)),
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

    if (prompt!.options.isEmpty && _currentSeq == widget.interactive.sequence) {
      return Container(
          padding: const EdgeInsets.all(20),
          height: size.height * 0.75,
          child: Column(children: [
            const SizedBox(height: 20),
            Text(prompt!.mainText),
            const Spacer(),
            Text(_i18n.translate("interactive_complete")),
            ElevatedButton.icon(
                onPressed: () {
                  _getInitialPath();
                },
                icon: isLoading
                    ? loadingButton(size: 16)
                    : const SizedBox.shrink(),
                label: Text(_i18n.translate("interactive_try_again_button"))),
            const SizedBox(height: 20),
            const TextDivider(text: "OR"),
            Text(_i18n.translate("interactive_read_comments_below"))
          ]));
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
              itemCount: widget.interactive.sequence * 2 + 1,
              itemBuilder: (context, index) {
                int itemCount = widget.interactive.sequence * 2;
                int midpoint = itemCount ~/ 2;
                if (itemCount % 2 == 1) {
                  midpoint -= 1;
                }
                if (index == 0) {
                  return Card(
                      child: Container(
                          color: Color(int.parse(
                              "0xFF${widget.interactive.theme.backgroundColor}")),
                          padding: const EdgeInsets.all(50),
                          child: Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              Column(
                                children: [
                                  Text(widget.interactive.title ?? "",
                                      style: TextStyle(
                                          fontSize: 24,
                                          color: Color(int.parse(
                                              "0xFF${widget.interactive.theme.titleColor}")))),
                                  const Divider(),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    widget.interactive.prompt,
                                    style: TextStyle(
                                        color: Color(int.parse(
                                            "0xFF${widget.interactive.theme.textColor}"))),
                                  ),
                                ],
                              ),
                              Positioned(
                                bottom: 20,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _nextPage();
                                    setState(() {
                                      _currentSeq++;
                                    });
                                  },
                                  child: Text(_i18n
                                      .translate("interactive_mode_start")),
                                ),
                              ),
                            ],
                          )));
                }
                if ((index + 1) % 2 == 0) {
                  int adjustedIndex = index ~/ 2;
                  if (adjustedIndex < widget.interactive.sequence) {
                    // Show the regular content using the original PageView.builder
                    return PageView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.interactive.sequence,
                        itemBuilder: (context, horizontalIndex) {
                          return Card(
                              child: Container(
                                  padding: const EdgeInsets.all(20),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: Column(
                                      children: [
                                        // TimelineHeader(user: user),
                                        const InlineAdaptiveAds(),
                                        Text(prompt!.mainText),
                                        isLoading
                                            ? const Frankloader()
                                            : const SizedBox(height: 20),
                                        ...prompt!.options
                                            .asMap()
                                            .entries
                                            .map((option) {
                                          int idx = option.key;
                                          String choice = option.value;
                                          if (idx <
                                              widget.interactive.sequence) {
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
                                                            .contains(choice)) {
                                                          _selectedChoices
                                                              .remove(choice);
                                                        } else {
                                                          _selectedChoices
                                                              .add(choice);
                                                        }
                                                      });
                                                      _getNextPath(
                                                          sequence:
                                                              adjustedIndex + 1,
                                                          choice: idx + 1,
                                                          showAds: index ==
                                                              midpoint);
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      child: Text(
                                                          choice.length > 3
                                                              ? choice
                                                                  .substring(3)
                                                              : choice),
                                                    )));
                                          }
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(top: 10),
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
                if (index - 1 == midpoint) {
                  return InterstitialAds(
                    onAdStatus: (data) {
                      String stats = data["status"];

                      setState(() {
                        _adTime = stats == "closed" ? 0 : 5;
                      });
                    },
                  );
                }
                return Card(
                  color: Colors.white12,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Color(int.parse(
                            "0xFF${widget.interactive.theme.backgroundColor}")),
                        image: DecorationImage(
                            image: widget.interactive.photoUrl != null
                                ? CachedNetworkImageProvider(
                                    widget.interactive.photoUrl!,
                                    errorListener: () =>
                                        const Icon(Icons.error),
                                  )
                                : Image.asset(
                                    "assets/images/blank.jpg",
                                    scale: 0.2,
                                    width: 100,
                                  ).image,
                            fit: BoxFit.cover)),
                    child: Center(
                        child: Column(
                      children: [
                        loadingButton(size: 40),
                        const Text("An image is here")
                      ],
                    )),
                  ),
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
    try {
      InteractiveBoardPrompt p = await _interaciveApi
          .getInteractiveId(widget.interactive.interactiveId);
      setState(() {
        prompt = p;
      });
    } catch (err, s) {
      Get.snackbar(
          _i18n.translate("error"), _i18n.translate("an_error_has_occurred"),
          snackPosition: SnackPosition.TOP,
          backgroundColor: APP_ERROR,
          colorText: Colors.black);
      await FirebaseCrashlytics.instance.recordError(err, s,
          reason:
              'Cannot get interactive id: ${widget.interactive.interactiveId}',
          fatal: true);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _getNextPath(
      {required int choice, required int sequence, required showAds}) async {
    if (showAds == true) {
      _nextPage();

      await Future.delayed(Duration(seconds: _adTime));
    }
    // Step 1: Scroll to the right with a delay
    if (_pageController.page!.toInt() < widget.interactive.sequence * 2 - 1) {
      await Future.delayed(const Duration(milliseconds: 1000));
      _nextPage();
    }

    Map<String, dynamic> userResponse = {
      "option": choice,
      "interactiveId": widget.interactive.interactiveId,
      "sequence": sequence,
      "action": prompt!.mainText + prompt!.options.join(" ")
    };
    InteractiveBoardPrompt p =
        await _interaciveApi.getNextPath(userResponse: userResponse);

    // Step 2: Scroll down after the API call is complete
    if (_pageController.page!.toInt() < widget.interactive.sequence * 2 - 1) {
      _nextPage();
    }

    setState(() {
      prompt = p;
      _currentSeq += 1;
    });
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 1000),
      curve: Curves.ease,
    );
  }
}
