import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:machi_app/api/machi/script_api.dart';
import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/script.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/screens/storyboard/page/page_view.dart';
import 'package:machi_app/widgets/storyboard/my_edit/edit_page_reorder.dart';
import 'package:machi_app/widgets/storyboard/my_edit/layout_edit.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class EditPage extends StatefulWidget {
  final Story passStory;
  const EditPage({Key? key, required this.passStory}) : super(key: key);

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final StoryboardController storyboardController = Get.find(tag: 'storyboard');

  final PageController _pageController =
      PageController(viewportFraction: 1, keepPage: true);

  late Story story;
  late AppLocalizations _i18n;
  final _scriptApi = ScriptApi();

  Layout selectedLayout = Layout.CONVO;
  int pageIndex = 0;

  /// Detects if user is trying to continue to the same page or go on to the next page.
  bool _userScrolledAgain = false;

  /// Determines if there are any changes that needs to be called to api.
  bool _hasChanges = false;

  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();

    setState(() {
      story = widget.passStory;
      selectedLayout = widget.passStory.layout ?? Layout.CONVO;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollTimer?.cancel();
    _pageController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _i18n = AppLocalizations.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          return Future.value(true);
        },
        child: Scaffold(
            appBar: AppBar(
              centerTitle: false,
              leadingWidth: 50,
              title: Text(
                _i18n.translate("creative_mix_edit"),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              leading: BackButton(
                color: Theme.of(context).primaryColor,
                onPressed: () async {
                  _onSaveAllSequence(); // on last page, if page didn't move

                  Navigator.of(context).pop();

                  /// go back to list of storyboard
                  /// 1. if there are updates, the page view doesnt get updated
                  /// 2. there's too many back to press
                  Navigator.of(context).pop();
                },
              ),
              actions: [
                Container(
                    padding: const EdgeInsets.all(10.0),
                    child: TextButton(
                        onPressed: () {
                          _onSaveAllSequence();
                          Get.to(() =>
                              StoryPageView(story: story, isPreview: true));
                        },
                        child: Text(_i18n.translate("creative_mix_preview"))))
              ],
            ),
            body: Stack(
              children: _showPageWidget(),
            )));
  }

  List<Widget> _showPageWidget() {
    Size size = MediaQuery.of(context).size;
    if (story.pages!.isEmpty) {
      Script emptyScript = Script(
          scriptId: "",
          characterId: UserModel().user.userId,
          characterName: UserModel().user.username);
      return [
        EditPageReorder(
            story: story,
            scriptList: [emptyScript],
            pageIndex: pageIndex,
            layout: selectedLayout,
            onMoveInsertPages: (data) {
              _onMoveInsertPages(data);
            },
            onUpdateSeq: (update) {
              _onUpdateSequence(update);
            },
            onSingleUpdate: (update) {
              // updates that involve not moving entire page components
              setState(() {
                story = update;
              });
            },
            onLayoutSelection: (layout) {
              selectedLayout = layout;
              _onUpdateLayout(layout);
            })
      ];
    }

    return [
      NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            /// @todo duplicate function in page_view.dart
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
                _pageController.nextPage(
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
              _pageController.previousPage(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeIn,
              );
            } else {
              if (currentPos < 0 && direction == ScrollDirection.reverse) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                );
              }
            }

            return false;
          },
          child: Container(
              padding: const EdgeInsets.all(5),
              height: size.height - 100,
              width: double.infinity,
              child: Obx(() => PageView.builder(
                    onPageChanged: _onPageChange,
                    controller: _pageController,
                    itemCount: storyboardController.currentStory.pages!.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (_, index) {
                      List<Script> scripts = storyboardController
                              .currentStory.pages![index].scripts ??
                          [];
                      return EditPageReorder(
                          story: storyboardController.currentStory,
                          scriptList: scripts,
                          pageIndex: index,
                          layout: selectedLayout,
                          onMoveInsertPages: (data) {
                            _onMoveInsertPages(data);
                          },
                          onUpdateSeq: (update) {
                            /// will save if there is updated sequence on exit
                            _onUpdateSequence(update);
                          },
                          onSingleUpdate: (update) {
                            // updates that involve not moving entire page components
                            setState(() {
                              story = update;
                            });
                          },
                          onLayoutSelection: (layout) {
                            selectedLayout = layout;
                            _onUpdateLayout(layout);
                          });
                    },
                  )))),
      Positioned(
          left: 10,
          width: 10,
          top: size.height / 4,
          child: SizedBox(
            width: 50,
            height: size.height / 2,
            child: SmoothPageIndicator(
              axisDirection: Axis.vertical,
              controller: _pageController,
              count: story.pages?.length ?? 1,
              effect: const ExpandingDotsEffect(
                  dotHeight: 5, dotWidth: 5, activeDotColor: APP_ACCENT_COLOR),
            ),
          )),
    ];
  }

  /// update / delete sequence
  /// EditPage for child, story for parent state
  void _onMoveInsertPages(Map<String, dynamic> data) {
    switch (data["action"]) {
      case ("add"):
        int pageNum = story.pages!.length;
        if (story.pages![pageNum - 1].scripts!.isNotEmpty) {
          StoryPages storyPage = StoryPages(pageNum: pageNum + 1, scripts: []);
          story.pages!.add(storyPage);
          storyboardController.updateStory(story: story);

          setState(() {
            story = story;
          });
        }
        break;
      case ("move"):
        int moveToPage = data["page"];
        Script moveScript = data["script"];

        for (int i = 0; i < story.pages!.length; i++) {
          story.pages![i].scripts!
              .removeWhere((script) => script.scriptId == moveScript.scriptId);
        }
        story.pages![moveToPage - 1].scripts!.add(moveScript);
        storyboardController.updateStory(story: story);
        break;

      default:
        break;
    }
  }

  void _onUpdateSequence(List<Script> scripts) async {
    StoryPages newPages = story.pages![pageIndex].copyWith(scripts: scripts);
    story.pages![pageIndex] = newPages;
    storyboardController.updateStory(story: story);
    setState(() {
      _hasChanges = true;
    });
  }

  /// Save any layout updates.
  void _onUpdateLayout(Layout layout) async {
    final storyApi = StoryApi();
    Story updateStory = story.copyWith(layout: layout);

    await storyApi.updateStory(story: updateStory, layout: layout.name);
    setState(() {
      story = updateStory;
    });
    storyboardController.updateStory(story: updateStory);
  }

  /// When the user swipes to another page, indicate a chage.
  void _onPageChange(int index) {
    _onSaveAllSequence();

    setState(() {
      pageIndex = index;
    });
  }

  /// Save the sequence on the page.
  void _onSaveAllSequence() async {
    if (_hasChanges == true) {
      try {
        List<Script> scripts =
            storyboardController.currentStory.pages![pageIndex].scripts!;
        await _scriptApi.updateScripts(scripts: scripts);
      } catch (err, s) {
        Get.snackbar(
          _i18n.translate("error"),
          _i18n.translate("an_error_has_occurred"),
          snackPosition: SnackPosition.TOP,
          backgroundColor: APP_ERROR,
        );
        await FirebaseCrashlytics.instance.recordError(err, s,
            reason: 'Unable to update sequence', fatal: true);
      } finally {
        if (mounted) {
          setState(() {
            _hasChanges = false;
          });
        }
      }
    }
  }
}
