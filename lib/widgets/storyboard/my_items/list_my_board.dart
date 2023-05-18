import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/helpers/date_format.dart';
import 'package:machi_app/widgets/no_data.dart';
import 'package:machi_app/widgets/storyboard/storyboard_item_widget.dart';
import 'package:machi_app/widgets/storyboard/view_storyboard.dart';
import 'package:get/get.dart';

class ListMyStories extends StatefulWidget {
  final types.Message? message;
  const ListMyStories({Key? key, this.message}) : super(key: key);

  @override
  _MyStoriesState createState() => _MyStoriesState();
}

class _MyStoriesState extends State<ListMyStories> {
  late AppLocalizations _i18n;
  double itemHeight = 120;
  final _storyApi = StoryApi();
  StoryboardController storyboardController = Get.find(tag: 'storyboard');

  @override
  void initState() {
    storyboardController.getUnpublised();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    return RefreshIndicator(
        onRefresh: () async {
          // Refresh Functionality
          await _storyApi.getMyStories();
        },
        child: storyboardController.stories.isEmpty
            ? Align(
                alignment: Alignment.center,
                child: Text(
                  _i18n.translate("story_nothing"),
                  textAlign: TextAlign.center,
                ),
              )
            : Obx(
                () => ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: storyboardController.unpublished.length,
                    itemBuilder: (BuildContext ctx, index) {
                      Storyboard story =
                          storyboardController.unpublished[index];
                      if (story.title == '') {
                        return NoData(
                            text: _i18n.translate("storycast_board_nothing"));
                      }
                      return InkWell(
                          onTap: () {
                            _onStoryClick(index, story);
                          },
                          child: StoryboardItemWidget(
                              item: storyboardController.unpublished[index]));
                    }),
              ));
  }

  void _addMessage(int index, Storyboard story) async {
    try {
      await _storyApi.addStory(index, widget.message!.id, story.storyboardId);
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

  void _onStoryClick(int index, Storyboard story) {
    widget.message != null
        ? _addMessage(index, story)
        : _setCurrentStory(story);
  }

  void _setCurrentStory(Storyboard story) {
    storyboardController.currentStory = story;
    Get.to(() => ViewStoryboard());
  }

  Widget _showMessage(BuildContext context, List<Story> story) {
    if (story.isEmpty) {
      return const SizedBox.shrink();
    }
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // if (firstText != null)
        //   SizedBox(
        //     width: firstImage != null ? width * 0.65 - 20 : width - 40,
        //     height: itemHeight - 60,
        //     child: Text(
        //       story.title,
        //       style: Theme.of(context).textTheme.bodySmall,
        //       // overflow: TextOverflow.ellipsis,
        //     ),
        //   ),
      ],
    );
  }
}
