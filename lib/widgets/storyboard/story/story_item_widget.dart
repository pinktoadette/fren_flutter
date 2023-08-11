import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/machi/script_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/controller/timeline_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/helpers/date_format.dart';
import 'package:machi_app/screens/storyboard/page_view.dart';
import 'package:machi_app/widgets/story_cover.dart';
import 'package:onboarding/onboarding.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class StoryItemWidget extends StatefulWidget {
  final Storyboard? storyboard;
  final Story story;
  final bool disablePress;
  final types.Message? message;
  const StoryItemWidget(
      {Key? key,
      required this.story,
      this.message,
      this.disablePress = false,
      this.storyboard})
      : super(key: key);

  @override
  State<StoryItemWidget> createState() => _StoryItemWidgetState();
}

class _StoryItemWidgetState extends State<StoryItemWidget> {
  late AppLocalizations _i18n;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  TimelineController timelineController = Get.find(tag: 'timeline');

  List<PageModel>? pageList;
  final _scriptApi = ScriptApi();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;
    double storyCoverWidth = 80;
    double padding = 15;
    double playWidth =
        widget.story.status == StoryStatus.PUBLISHED ? PLAY_BUTTON_WIDTH : 0;
    String timestampLabel = widget.story.status == StoryStatus.PUBLISHED
        ? "Published on "
        : "Last Updated ";
    double contentWidth = width - (storyCoverWidth + playWidth + padding * 3);
    return InkWell(
        onTap: () {
          if (widget.disablePress == true) {
            null;
          } else {
            timelineController.setStoryTimelineControllerCurrent(widget.story);

            if (widget.message != null) {
              _addMessage();
            } else {
              storyboardController.onGoToPageView(widget.story);
              Get.to(() => StoryPageView(story: widget.story));
            }
          }
        },
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(padding),
                child: StoryCover(
                    height: storyCoverWidth,
                    width: storyCoverWidth,
                    photoUrl: widget.story.photoUrl ?? "",
                    title: widget.story.title),
              ),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                        width: contentWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 15,
                            ),
                            Text(
                                "$timestampLabel ${formatDate(widget.story.updatedAt ?? getDateTimeEpoch())}",
                                style: const TextStyle(fontSize: 10)),
                            Text(
                              widget.story.title,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    if (widget.story.status == StoryStatus.UNPUBLISHED)
                      const Icon(
                        Iconsax.lock,
                        size: 16,
                      ),
                  ]),
            ],
          ),
        ]));
  }

  void _addMessage() async {
    try {
      Map<String, dynamic> messageMap = widget.message!.toJson();
      StoryPages pages = await _scriptApi.addScriptToStory(
          type: messageMap["type"],
          character: messageMap["author"]["firstName"],
          text: messageMap["text"],
          characterId: messageMap["author"]["id"],
          image: messageMap["uri"] != null
              ? {
                  "uri": messageMap["uri"],
                  "size": messageMap["size"],
                  "height": messageMap["height"],
                  "width": messageMap["width"]
                }
              : null,
          pageNum: 1,
          storyId: widget.story.storyId);
      storyboardController.addNewScriptToStory(pages);

      int count = 0;
      Get.until((route) => count++ >= 2);
      Get.snackbar(
          _i18n.translate("story_added"), _i18n.translate("story_added_info"),
          snackPosition: SnackPosition.TOP,
          backgroundColor: APP_SUCCESS,
          colorText: Colors.black);
    } catch (err, s) {
      debugPrint(err.toString());
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
      await FirebaseCrashlytics.instance.recordError(err, s,
          reason: 'Cannot add message from story item', fatal: true);
    }
  }
}
