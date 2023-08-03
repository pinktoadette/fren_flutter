import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/script.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/screens/storyboard/page_view.dart';
import 'package:machi_app/widgets/storyboard/my_edit/edit_page_reorder.dart';
import 'package:machi_app/widgets/storyboard/my_edit/layout_edit.dart';
import 'package:machi_app/widgets/storyboard/my_edit/page_direction_edit.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// Need to call pages since storyboard
/// did not query this in order to increase speed
class EditPage extends StatefulWidget {
  final Story passStory;
  const EditPage({Key? key, required this.passStory}) : super(key: key);

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final PageController _pageController =
      PageController(viewportFraction: 1, keepPage: true);

  late AppLocalizations _i18n;
  double itemHeight = 120;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  late Story story;
  Layout selectedLayout = Layout.CONVO;

  int pageIndex = 0;
  bool _userScrolledAgain = false;
  Timer? _scrollTimer;

  @override
  void initState() {
    _setupPages();
    super.initState();
  }

  void _setupPages() {
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
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            _i18n.translate("storybits_edit"),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          leading: BackButton(
            color: Theme.of(context).primaryColor,
            onPressed: () async {
              Navigator.pop(context, story);
            },
          ),
          actions: [
            Container(
                padding: const EdgeInsets.all(10.0),
                child: OutlinedButton(
                    onPressed: () {
                      Get.to(
                          () => StoryPageView(story: story, isPreview: true));
                    },
                    child: Text(_i18n.translate("storyboard_preview"))))
          ],
        ),
        body: Stack(
          children: [
            ..._showPageWidget(),
          ],
        ));
  }

  List<Widget> _showPageWidget() {
    Size size = MediaQuery.of(context).size;
    if (story.pages!.isEmpty) {
      return [
        EditPageReorder(
            story: story,
            scriptList: const [],
            pageIndex: pageIndex,
            layout: selectedLayout,
            onMoveInsertPages: (data) {
              _moveInsertPages(data);
            },
            onUpdateSeq: (update) {
              _updateSequence(update);
            },
            onPageAxisDirection: (direction) {
              // update
              _updatePageDirection(direction);
            },
            onLayoutSelection: (layout) {
              selectedLayout = layout;
            })
      ];
    }

    return [
      NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            /// @ttodo duplicate function in page_view.dart
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
              child: PageView.builder(
                onPageChanged: _onPageChange,
                controller: _pageController,
                itemCount: story.pages!.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (_, index) {
                  List<Script> scripts = story.pages![index].scripts ?? [];
                  return EditPageReorder(
                      story: story,
                      scriptList: scripts,
                      pageIndex: index,
                      layout: selectedLayout,
                      onMoveInsertPages: (data) {
                        _moveInsertPages(data);
                      },
                      onUpdateSeq: (update) {
                        _updateSequence(update);
                      },
                      onPageAxisDirection: (direction) {
                        _updatePageDirection(direction);
                      },
                      onLayoutSelection: (layout) {
                        selectedLayout = layout;
                        _updateLayout(layout);
                      });
                },
              ))),
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
                  dotHeight: 10,
                  dotWidth: 18,
                  activeDotColor: APP_ACCENT_COLOR),
            ),
          )),
    ];
  }

  void _updatePageDirection(PageDirection direction) {
    Story update = story.copyWith(pageDirection: direction);
    storyboardController.updateStory(story: update);

    setState(() {
      story = update;
    });
  }

  /// update / delete sequence
  /// EditPage for child, story for parent state
  void _moveInsertPages(Map<String, dynamic> data) {
    switch (data["action"]) {
      case ("add"):
        int pageNum = story.pages!.length;
        if (story.pages![pageNum - 1].scripts!.isNotEmpty) {
          StoryPages storyPage = StoryPages(pageNum: pageNum + 1, scripts: []);
          story.pages!.add(storyPage);
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

  void _updateSequence(List<Script> scripts) async {
    StoryPages newPages = story.pages![pageIndex].copyWith(scripts: scripts);
    story.pages![pageIndex] = newPages;
    storyboardController.updateStory(story: story);
  }

  void _updateLayout(Layout layout) async {
    final _storyApi = StoryApi();
    Story updateStory = story.copyWith(layout: layout);

    await _storyApi.updateStory(story: updateStory, layout: layout.name);
    setState(() {
      story = updateStory;
    });
  }

  void _onPageChange(int index) {
    setState(() {
      pageIndex = index;
    });
  }
}
