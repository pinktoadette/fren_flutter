import 'package:machi_app/api/machi/script_api.dart';
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
  final _scriptApi = ScriptApi();
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
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Edit " + _i18n.translate("storybits"),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          leading: BackButton(
            color: Theme.of(context).primaryColor,
            onPressed: () async {
              // await _saveSequence();
              Get.back();
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
                SizedBox(
                    height: height - 100,
                    width: width,
                    child: PageView.builder(
                      onPageChanged: _onPageChange,
                      controller: _pageController,
                      itemCount: story.pages?.length ?? 0,
                      itemBuilder: (_, index) {
                        var scripts = story.pages![index].scripts ?? [];
                        return EditPageReorder(
                            scriptList: scripts,
                            pageIndex: pageIndex,
                            onSave: (isClicked) {
                              _saveSequence();
                            },
                            onMoveInsertPages: (data) {
                              _moveInsertPages(data);
                            },
                            onUpdateSeq: (update) {
                              _updateSequence(update);
                            },
                            onUpdateDelete: (data) {
                              _updateDelUpdateSequence(data);
                            });
                      },
                    )),
                Positioned.fill(
                  bottom: 50,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SmoothPageIndicator(
                      controller: _pageController,
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

  /// update / delete sequence
  /// EditPage for child, story for parent state
  void _moveInsertPages(Map<String, dynamic> data) {
    switch (data["action"]) {
      case ("add"):
        int pageNum = story.pages!.length;
        if (story.pages![pageNum - 1].scripts!.isNotEmpty) {
          StoryPages storyPage =
              StoryPages(pageNum: story.pages?.length ?? 1, scripts: []);
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

        storyboardController.updateScriptsToStory(
            story: story, pages: story.pages!);
        break;
      default:
        break;
    }
  }

  /// Delete sequence
  /// Delete is immediately saved in child component.
  /// Update is saved here in parent.
  /// StoryPage includes scripts from backend in all request
  void _updateDelUpdateSequence(List<StoryPages> page) {
    storyboardController.updateScriptsToStory(story: story, pages: page);
  }

  void _updateSequence(List<Script> scripts) async {
    StoryPages newPages = story.pages![pageIndex].copyWith(scripts: scripts);
    story.pages![pageIndex] = newPages;
    _updateDelUpdateSequence(story.pages!);
  }

  void _saveSequence() async {
    try {
      List<Map<String, dynamic>> listScripts = [];
      for (int i = 0; i < story.pages!.length; i++) {
        List<Script> scripts = story.pages![i].scripts!;
        for (int j = 0; j < scripts.length; j++) {
          Script script = scripts[j];
          listScripts.add({
            SCRIPT_ID: script.scriptId,
            SCRIPT_PAGE_NUM: i,
            SCRIPT_SEQUENCE_NUM: j
          });
        }
      }

      await _scriptApi.updateSequence(scripts: listScripts);
    } catch (err) {
      debugPrint(err.toString());
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_ERROR,
      );
    }
  }

  void _onPageChange(int index) {
    setState(() {
      pageIndex = index;
    });
  }
}
