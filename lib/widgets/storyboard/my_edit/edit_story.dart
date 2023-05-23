import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/script.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/widgets/common/no_data.dart';
import 'package:machi_app/widgets/storyboard/my_edit/edit_page_reorder.dart';
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
  final _controller = PageController(viewportFraction: 1, keepPage: true);

  late AppLocalizations _i18n;
  double itemHeight = 120;
  final _storyApi = StoryApi();
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  late Story story;
  int pageIndex = 0;
  var pages = [];

  get onUpdate => null;

  @override
  void initState() {
    _setupPages();
    super.initState();
  }

  void _setupPages() {
    setState(() {
      story = widget.passStory;
    });
    pages = _getPages();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    if (pages.isEmpty) {
      return Scaffold(
          appBar: AppBar(
            title: Text(
              _i18n.translate("storybits"),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          body: NoData(text: _i18n.translate("loading")));
    }
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Edit " + _i18n.translate("storybits"),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        body: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                    height: height - 100,
                    width: width,
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: story.pages?.length ?? 0,
                      itemBuilder: (_, index) {
                        /// EditPage for child, story for parent state
                        /// Tried using pages, error
                        return pages[index];
                      },
                    )),
                Positioned.fill(
                  bottom: 50,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SmoothPageIndicator(
                      controller: _controller,
                      count: story.pages?.length ?? 0,
                      effect: const ExpandingDotsEffect(
                          dotHeight: 14,
                          dotWidth: 14,
                          // type: WormType.thinUnderground,
                          activeDotColor: APP_ACCENT_COLOR),
                    ),
                  ),
                )
              ],
            ),
          ],
        )));
  }

  List _getPages() {
    /// Separate out the reorder to have its own state\
    List<EditPageReorder> pages = [];
    for (var i = 0; i < story.pages!.length; i++) {
      var scripts = story.pages![i].scripts ?? [];
      EditPageReorder page = EditPageReorder(
          scriptList: scripts,
          pageIndex: pageIndex,
          onMoveInsertPages: (data) {
            _moveInsertPages(data);
          },
          onUpdate: (data) {
            _updateSequence(data);
          });
      pages.add(page);
    }
    return pages;
  }

  /// update / delete sequence
  /// EditPage for child, story for parent state
  void _moveInsertPages(Map<String, dynamic> data) {
    if (data["action"] == "add") {
      int pageNum = story.pages!.length;
      EditPageReorder page = EditPageReorder(
          scriptList: [],
          pageIndex: pageNum,
          onMoveInsertPages: (data) {
            _moveInsertPages(data);
          },
          onUpdate: (data) {
            _updateSequence(data);
          });
      if (story.pages![pageNum - 1].scripts != null) {
        pages.add(page);
        StoryPages storyPage =
            StoryPages(pageNum: story.pages?.length ?? 1, scripts: null);
        story.pages!.add(storyPage);
      }

      setState(() {
        pages = pages;
      });
      _controller.jumpToPage(pageNum);
    }
  }

  /// update / delete sequence
  /// StoryPage includes scripts from backend in all request
  void _updateSequence(List<StoryPages> page) {
    storyboardController.updateScriptsToStory(story: story, pages: page);
  }
}
