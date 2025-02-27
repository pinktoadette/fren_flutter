import 'package:dio/dio.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/widgets/ads/inline_ads.dart';
import 'package:machi_app/widgets/storyboard/storyboard_item_widget.dart';
import 'package:machi_app/widgets/storyboard/view_storyboard.dart';

class ListPublishBoard extends StatefulWidget {
  final types.Message? message;
  const ListPublishBoard({Key? key, this.message}) : super(key: key);

  @override
  State<ListPublishBoard> createState() => _ListPublishBoardState();
}

class _ListPublishBoardState extends State<ListPublishBoard> {
  double itemHeight = 150;
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  final _cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
    _getMyBoards();
  }

  @override
  void dispose() {
    super.dispose();
    _cancelToken.cancel();
  }

  void _getMyBoards() async {
    await storyboardController.getBoards(
        filter: StoryStatus.PUBLISHED, cancelToken: _cancelToken);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return RefreshIndicator(
        onRefresh: () async {
          _getMyBoards();
        },
        child: Obx(() => ListView.separated(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: storyboardController.published.length,
            itemBuilder: (BuildContext ctx, index) {
              Storyboard story = storyboardController.published[index];
              return InkWell(
                  onTap: () {
                    _onStoryClick(index, story);
                  },
                  child: StoryboardItemWidget(
                      item: storyboardController.published[index]));
            },
            separatorBuilder: (BuildContext context, int index) {
              if ((index + 1) % 3 == 0) {
                return Padding(
                  padding:
                      const EdgeInsetsDirectional.only(top: 10, bottom: 10),
                  child: Container(
                    height: AD_HEIGHT,
                    width: width,
                    color: Theme.of(context).colorScheme.background,
                    child: const InlineAdaptiveAds(),
                  ),
                );
              } else {
                return const Divider();
              }
            })));
  }

  void _onStoryClick(int index, Storyboard story) {
    storyboardController.currentStoryboard = story;
    Get.to(() => const ViewStoryboard());
  }
}
