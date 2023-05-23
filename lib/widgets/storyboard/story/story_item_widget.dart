import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/machi/script_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/helpers/date_format.dart';
import 'package:machi_app/screens/storyboard/page_view.dart';
import 'package:machi_app/widgets/story_cover.dart';
import 'package:machi_app/widgets/timeline/timeline_header.dart';
import 'package:onboarding/onboarding.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class StoryItemWidget extends StatefulWidget {
  final Story story;
  final types.Message? message;
  const StoryItemWidget({Key? key, required this.story, this.message})
      : super(key: key);

  @override
  _StoryItemWidgetState createState() => _StoryItemWidgetState();
}

class _StoryItemWidgetState extends State<StoryItemWidget> {
  late AppLocalizations _i18n;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  List<PageModel>? pageList;
  final _scriptApi = ScriptApi();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;
    double storyCoverWidth = 80;
    double padding = 15;
    double playWidth =
        widget.story.status == StoryStatus.PUBLISHED ? PLAY_BUTTON_WIDTH : 0;

    return InkWell(
        onTap: () {
          storyboardController.setCurrentStory(widget.story);
          if (widget.message != null) {
            _addMessage();
          } else {
            Get.to(() => StoryPageView(story: widget.story));
          }
        },
        child: Card(
            elevation: 1,
            semanticContainer: true,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(padding),
                    child: StoryCover(
                        width: storyCoverWidth,
                        photoUrl: widget.story.photoUrl ?? "",
                        title: widget.story.title),
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                            width: width -
                                (storyCoverWidth + playWidth + padding * 3),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                    "update ${formatDate(widget.story.updatedAt!)}",
                                    style: const TextStyle(fontSize: 10)),
                                Text(
                                  widget.story.title,
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(widget.story.summary ?? "No summary",
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                              ],
                            ))
                      ]),
                ],
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TimelineHeader(user: widget.story.createdBy),
                      TextButton.icon(
                        onPressed: null,
                        icon: const Icon(Iconsax.square, size: 16),
                        label: Text("${widget.story.pages?.length ?? 0} mods",
                            style: const TextStyle(fontSize: 12)),
                      ),
                    ],
                  )),
            ])));
  }

  void _addMessage() async {
    try {
      Map<String, dynamic> messageMap = widget.message!.toJson();
      await _scriptApi.addScriptToStory(
          type: messageMap["type"],
          character: messageMap["author"]["firstName"],
          text: messageMap["text"],
          image: messageMap["uri"] != null
              ? {
                  "uri": messageMap["uri"],
                  "size": messageMap["size"],
                  "height": messageMap["height"],
                  "width": messageMap["width"]
                }
              : null,
          storyId: widget.story.storyId);
      Navigator.of(context).pop();
      Get.snackbar(
        _i18n.translate("story_added"),
        _i18n.translate("story_added_info"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_SUCCESS,
      );
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
}
