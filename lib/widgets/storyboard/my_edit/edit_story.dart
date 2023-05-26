import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/script.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/screens/storyboard/page_view.dart';
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
  final _pageController = PageController(viewportFraction: 1, keepPage: true);

  late AppLocalizations _i18n;
  double itemHeight = 120;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  late Story story;
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
    });
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);

    return Scaffold(
        appBar: AppBar(
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
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              children: [
                ..._showPageWidget(),
              ],
            ),
          ],
        )));
  }

  List<Widget> _showPageWidget() {
    Size size = MediaQuery.of(context).size;
    if (story.pages!.isEmpty) {
      return [
        SizedBox(
            height: size.height,
            width: size.width,
            child: EditPageReorder(
                scriptList: const [],
                pageIndex: pageIndex,
                onMoveInsertPages: (data) {
                  _moveInsertPages(data);
                },
                onUpdateSeq: (update) {
                  _updateSequence(update);
                }))
      ];
    }

    return [
      SizedBox(
          height: size.height,
          width: double.infinity,
          child: PageView.builder(
            onPageChanged: _onPageChange,
            controller: _pageController,
            itemCount: story.pages!.length,
            itemBuilder: (_, index) {
              List<Script> scripts = story.pages![index].scripts ?? [];
              return EditPageReorder(
                scriptList: scripts,
                pageIndex: pageIndex,
                onMoveInsertPages: (data) {
                  _moveInsertPages(data);
                },
                onUpdateSeq: (update) {
                  _updateSequence(update);
                },
              );
            },
          )),
      Positioned.fill(
        bottom: 150,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SmoothPageIndicator(
            controller: _pageController,
            count: story.pages?.length ?? 1,
            effect: const ExpandingDotsEffect(
                dotHeight: 14, dotWidth: 14, activeDotColor: APP_ACCENT_COLOR),
          ),
        ),
      )
    ];
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

        _pageController.animateToPage(pageNum,
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn);
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

  void _onPageChange(int index) {
    setState(() {
      pageIndex = index;
    });
  }
}
