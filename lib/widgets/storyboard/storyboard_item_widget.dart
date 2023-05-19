import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/api/machi/timeline_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/date_format.dart';
import 'package:machi_app/widgets/story_cover.dart';
import 'package:machi_app/screens/storyboard/story_view.dart';
import 'package:machi_app/widgets/storyboard/view_storyboard.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class StoryboardItemWidget extends StatefulWidget {
  final Storyboard item;
  final types.Message? message;
  const StoryboardItemWidget({Key? key, required this.item, this.message})
      : super(key: key);

  @override
  _StoryboardItemWidgettState createState() => _StoryboardItemWidgettState();
}

class _StoryboardItemWidgettState extends State<StoryboardItemWidget> {
  StoryboardController storyboardController = Get.find(tag: 'storyboard');

  late AppLocalizations _i18n;
  final _storyApi = StoryApi();
  final _timelineApi = TimelineApi();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;
    double storyCoverWidth = 120;
    double padding = 15;
    double playWidth =
        widget.item.status == StoryStatus.PUBLISHED ? PLAY_BUTTON_WIDTH : 0;
    return Card(
        elevation: 1,
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
                padding: EdgeInsets.all(padding),
                child: InkWell(
                    onTap: () async {
                      _onStoryClick();
                    },
                    child: StoryCover(
                        width: storyCoverWidth,
                        photoUrl: widget.item.photoUrl,
                        title: widget.item.title))),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () async {
                    _onStoryClick();
                  },
                  child: SizedBox(
                      width:
                          width - (storyCoverWidth + playWidth + padding * 3.2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.item.category,
                              style: Theme.of(context).textTheme.labelMedium),
                          Text(
                            widget.item.title,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                            height: 40,
                            child: Text(
                              widget.item.summary ?? "No summary",
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                onPressed: null,
                                icon: const Icon(Iconsax.menu_1),
                                label: Text(
                                    "${widget.item.story?.length} collection",
                                    style: const TextStyle(fontSize: 12)),
                              ),
                              if (widget.item.status != StoryStatus.PUBLISHED)
                                Text(
                                    "update ${formatDate(widget.item.updatedAt)}",
                                    style: const TextStyle(fontSize: 10))
                            ],
                          )
                        ],
                      )),
                ),
              ],
            ),
            if (widget.item.status == StoryStatus.PUBLISHED)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  LikeButton(
                    isLiked: widget.item.mylikes == 1 ? true : false,
                    onTap: (value) async {
                      await _onLikePressed(widget.item, !value);
                      return !value;
                    },
                    bubblesColor: BubblesColor(
                      dotPrimaryColor: APP_LIKE_COLOR,
                      dotSecondaryColor: Theme.of(context).primaryColor,
                    ),
                    likeBuilder: (bool isLiked) {
                      return Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? APP_LIKE_COLOR : Colors.grey,
                      );
                    },
                    likeCount: widget.item.likes,
                  ),
                ],
              )
          ],
        ));
  }

  Future<void> _onStoryClick() async {
    if (widget.message != null) {
      _showStories();
    } else {
      storyboardController.currentStoryboard = widget.item;
      // if (widget.item.story!.isNotEmpty) {
      //   /// Load the first story if any
      //   Story story =
      //       await _storyApi.getMyStories(widget.item.story![0].storyId);
      //   storyboardController.currentStory = story;
      // } else {
      //   storyboardController.currentStory = storyboardController.clearStory();
      // }

      Get.to(() => const StoriesView());
    }
  }

  Future<String> _onLikePressed(Storyboard item, bool value) async {
    return await _timelineApi.likeStoryMachi(
        "storyboard", item.storyboardId, value == true ? 1 : 0);
  }

  void _showStories() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const StoriesView()));
  }

  void _addMessage() async {
    try {
      await _storyApi.addItemToStory(widget.message!, widget.item.storyboardId);
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
