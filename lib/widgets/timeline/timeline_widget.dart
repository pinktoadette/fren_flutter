import 'package:flutter/material.dart';
import 'package:machi_app/api/machi/timeline_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/chatroom_controller.dart';
import 'package:machi_app/controller/timeline_controller.dart';
import 'package:machi_app/widgets/ads/inline_ads.dart';
import 'package:machi_app/widgets/timeline/timeline_row.dart';
import 'package:get/get.dart';

class TimelineWidget extends StatefulWidget {
  const TimelineWidget({Key? key}) : super(key: key);

  @override
  _TimelineWidgetState createState() => _TimelineWidgetState();
}

class _TimelineWidgetState extends State<TimelineWidget> {
  ChatController chatController = Get.find(tag: 'chatroom');
  TimelineController timelineController = Get.find(tag: 'timeline');
  final _timelineApi = TimelineApi();

  @override
  void initState() {
    _getTimeline();
    super.initState();
  }

  void _getTimeline() async {
    await _timelineApi.getTimeline();
  }

  @override
  Widget build(BuildContext context) {
    double itemHeight = 200;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return SizedBox(
        height: height - 200,
        child: RefreshIndicator(
            onRefresh: () {
              // Refresh Functionality
              return _timelineApi.getTimeline();
            },
            child: Obx(() => ListView.separated(
                cacheExtent: 1000,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) {
                  if ((index + 1) % 5 == 0) {
                    return Container(
                      height: itemHeight,
                      color: Theme.of(context).colorScheme.background,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(
                            top: 10, bottom: 10),
                        child: Container(
                          height: AD_HEIGHT,
                          width: width,
                          color: Theme.of(context).colorScheme.background,
                          child: const InlineAdaptiveAds(),
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
                itemCount: timelineController.feedList.length,
                itemBuilder: ((context, index) {
                  return TimelineRowWidget(
                      item: timelineController.feedList[index]);
                })))));
  }
}
