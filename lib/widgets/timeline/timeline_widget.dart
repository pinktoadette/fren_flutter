import 'package:flutter/material.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/chatroom_controller.dart';
import 'package:fren_app/controller/timeline_controller.dart';
import 'package:fren_app/widgets/ads/inline_ads.dart';
import 'package:fren_app/widgets/timeline/timeline_row.dart';
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
    double itemHeight = 200;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return SizedBox(
        height: height - 200,
        child: RefreshIndicator(
            onRefresh: () {
              // Refresh Functionality
              return timelineController.fetchMyTimeline();
            },
            child: Obx(() => ListView.separated(
                // cacheExtent: 1000,
                shrinkWrap: true,
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
                    return const Divider(height: 10);
                  }
                },
                itemCount: timelineController.feed.length,
                itemBuilder: ((context, index) {
                  return TimelineRowWidget(
                      item: timelineController.feed[index]);
                })))));
  }
}
