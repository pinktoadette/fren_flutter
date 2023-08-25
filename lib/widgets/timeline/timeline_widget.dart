import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:machi_app/controller/timeline_controller.dart';
import 'package:machi_app/controller/user_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/widgets/ads/inline_ads.dart';
import 'package:machi_app/widgets/announcement/inline_survey.dart';
import 'package:machi_app/widgets/common/no_data.dart';
import 'package:machi_app/widgets/storyboard/storyboard_item_widget.dart';
import 'package:get/get.dart';
import 'package:machi_app/widgets/timeline/latest_machi_gallery.dart';

class TimelineWidget extends StatefulWidget {
  const TimelineWidget({Key? key}) : super(key: key);

  @override
  State<TimelineWidget> createState() => _TimelineWidgetState();
}

class _TimelineWidgetState extends State<TimelineWidget> {
  UserController userController = Get.find(tag: 'user');
  TimelineController timelineController = Get.find(tag: 'timeline');

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _getContent() async {
    await Future.wait([
      timelineController.fetchHomepageItems(userController.user != null),
      timelineController.fetchPage(0, refresh: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return RefreshIndicator(
        onRefresh: () async {
          _getContent();
        },
        child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // const InlineAdaptiveAds(),
              const LatestWidget(),
              PagedListView<int, Storyboard>.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                pagingController: timelineController.pagingController,
                builderDelegate: PagedChildBuilderDelegate<Storyboard>(
                    firstPageProgressIndicatorBuilder: (_) =>
                        const SizedBox.shrink(),
                    newPageProgressIndicatorBuilder: (_) =>
                        const SizedBox.shrink(),
                    noItemsFoundIndicatorBuilder: (_) =>
                        const NoData(text: "No stories"),
                    itemBuilder: (context, item, index) {
                      return StoryboardItemWidget(
                          item: timelineController
                              .pagingController.itemList![index]);
                    }),
                separatorBuilder: (BuildContext context, int index) {
                  if ((index) % 3 == 0) {
                    return const InlineAdaptiveAds();
                  } else if ((index + 1) % 2 == 0 &&
                      (index == 1) &&
                      userController.user != null) {
                    return Padding(
                      padding:
                          const EdgeInsetsDirectional.only(top: 10, bottom: 10),
                      child: Container(
                        width: width,
                        color: Theme.of(context).colorScheme.background,
                        child: const InlineSurvey(),
                      ),
                    );
                  } else {
                    return const Divider();
                  }
                },
              )
            ])));
  }
}
