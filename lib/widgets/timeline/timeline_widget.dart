import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/chatroom_controller.dart';
import 'package:machi_app/controller/timeline_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/widgets/ads/inline_ads.dart';
import 'package:machi_app/widgets/animations/loader.dart';
import 'package:machi_app/widgets/announcement/inline_survey.dart';
import 'package:machi_app/widgets/storyboard/storyboard_item_widget.dart';
import 'package:get/get.dart';

class TimelineWidget extends StatefulWidget {
  const TimelineWidget({Key? key}) : super(key: key);

  @override
  _TimelineWidgetState createState() => _TimelineWidgetState();
}

class _TimelineWidgetState extends State<TimelineWidget> {
  ChatController chatController = Get.find(tag: 'chatroom');
  TimelineController timelineController = Get.find(tag: 'timeline');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return PagedSliverList<int, Storyboard>.separated(
      pagingController: timelineController.pagingController,
      builderDelegate: PagedChildBuilderDelegate<Storyboard>(
          firstPageProgressIndicatorBuilder: (_) => const Frankloader(),
          newPageProgressIndicatorBuilder: (_) => const Frankloader(),
          itemBuilder: (context, item, index) {
            return StoryboardItemWidget(item: item);
          }),
      separatorBuilder: (BuildContext context, int index) {
        if ((index + 1) % 3 == 0) {
          return Padding(
            padding: const EdgeInsetsDirectional.only(top: 10, bottom: 10),
            child: Container(
              height: AD_HEIGHT,
              width: width,
              color: Theme.of(context).colorScheme.background,
              child: const InlineAdaptiveAds(),
            ),
          );
        } else if ((index + 1) % 4 == 0 && (index == 3)) {
          return Padding(
            padding: const EdgeInsetsDirectional.only(top: 10, bottom: 10),
            child: Container(
              width: width,
              color: Theme.of(context).colorScheme.background,
              child: const InlineSurvey(),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
