import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:machi_app/api/machi/story_api.dart';
import 'package:machi_app/api/machi/storyboard_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
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
  final _storyboardApi = StoryboardApi();
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
          await _storyboardApi.getMyStoryboards(
              statusFilter: StoryStatus.UNPUBLISHED.name);
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
                      return StoryboardItemWidget(
                          message: widget.message,
                          item: storyboardController.unpublished[index]);
                    }),
              ));
  }
}
