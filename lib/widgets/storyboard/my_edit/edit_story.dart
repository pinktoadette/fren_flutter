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
  final _pageController = PageController(viewportFraction: 1, keepPage: true);

  late AppLocalizations _i18n;
  double itemHeight = 120;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  late Story story;
  Layout selectedLayout = Layout.CONVO;
  PageDirection _pageDirection = PageDirection.HORIZONTAL;

  int pageIndex = 0;

  get onUpdate => null;

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
        body: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Stack(
              children: [
                ..._showPageWidget(),
              ],
            )));
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
      SizedBox(
          height: size.height - 100,
          width: double.infinity,
          child: PageView.builder(
            onPageChanged: _onPageChange,
            controller: _pageController,
            itemCount: story.pages!.length,
            scrollDirection: _pageDirection == PageDirection.HORIZONTAL
                ? Axis.horizontal
                : Axis.vertical,
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
                    // update
                    _updatePageDirection(direction);
                  },
                  onLayoutSelection: (layout) {
                    selectedLayout = layout;
                    _updateLayout(layout);
                  });
            },
          )),
      Positioned(
          bottom: _pageDirection == PageDirection.HORIZONTAL ? 30 : 50,
          height: 30,
          left: _pageDirection == PageDirection.HORIZONTAL ? 0 : 20,
          width: size.width,
          child: Container(
            width: size.width,
            alignment: _pageDirection == PageDirection.HORIZONTAL
                ? Alignment.center
                : Alignment.bottomLeft,
            child: SmoothPageIndicator(
              axisDirection: _pageDirection == PageDirection.VERTICAL
                  ? Axis.vertical
                  : Axis.horizontal,
              controller: _pageController,
              count: story.pages?.length ?? 1,
              effect: ExpandingDotsEffect(
                  dotHeight: 8,
                  dotWidth: _pageDirection == PageDirection.HORIZONTAL ? 14 : 8,
                  activeDotColor: APP_ACCENT_COLOR),
            ),
          )),
    ];
  }

  void _updatePageDirection(PageDirection direction) {
    Story update = story.copyWith(pageDirection: direction);
    storyboardController.updateStory(story: update);

    setState(() {
      _pageDirection = direction;
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
