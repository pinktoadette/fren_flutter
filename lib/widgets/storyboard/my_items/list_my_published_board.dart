import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:machi_app/api/machi/storyboard_api.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/widgets/common/no_data.dart';
import 'package:machi_app/widgets/storyboard/storyboard_item_widget.dart';
import 'package:machi_app/widgets/storyboard/view_storyboard.dart';

class ListPublishBoard extends StatefulWidget {
  final types.Message? message;
  const ListPublishBoard({Key? key, this.message}) : super(key: key);

  @override
  _ListPublishBoardState createState() => _ListPublishBoardState();
}

class _ListPublishBoardState extends State<ListPublishBoard> {
  late AppLocalizations _i18n;
  double itemHeight = 150;
  final _storyboardApi = StoryboardApi();
  StoryboardController storyboardController = Get.find(tag: 'storyboard');

  @override
  void initState() {
    storyboardController.getBoards(filter: StoryStatus.PUBLISHED);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            _i18n.translate("story_published"),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        body: RefreshIndicator(
            onRefresh: () async {
              // Refresh Functionality
              await _storyboardApi.getMyStoryboards(
                  statusFilter: StoryStatus.PUBLISHED.name);
            },
            child: storyboardController.published.isEmpty
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
                        itemCount: storyboardController.published.length,
                        itemBuilder: (BuildContext ctx, index) {
                          Storyboard story =
                              storyboardController.published[index];
                          if (story.title == '') {
                            return NoData(
                                text: _i18n.translate("storyboard_nothing"));
                          }
                          return InkWell(
                              onTap: () {
                                _onStoryClick(index, story);
                              },
                              child: StoryboardItemWidget(
                                  item: storyboardController.published[index]));
                        }),
                  )));
  }

  void _onStoryClick(int index, Storyboard story) {
    storyboardController.currentStoryboard = story;
    Get.to(() => const ViewStoryboard());
  }
}
