import 'package:flutter/material.dart';
import 'package:fren_app/api/machi/timeline_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/chatroom_controller.dart';
import 'package:fren_app/datas/timeline.dart';
import 'package:fren_app/widgets/ads/inline_ads.dart';
import 'package:fren_app/widgets/timeline/timeline_row.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class TimelineWidget extends StatefulWidget {
  const TimelineWidget({Key? key}) : super(key: key);

  @override
  _TimelineWidgetState createState() => _TimelineWidgetState();
}

class _TimelineWidgetState extends State<TimelineWidget> {
  final _timelineApi = TimelineApi();
  ChatController chatController = Get.find(tag: 'chatroom');
  static const _pageSize = 20;

  final PagingController<int, dynamic> _pagingController =
      PagingController(firstPageKey: 0);

  Future<void> _getTimeline(int pageKey) async {
    try {
      List<Timeline> newItems =
          await _timelineApi.getTimeline(_pageSize, pageKey);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _getTimeline(pageKey);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double itemHeight = 200;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Container(
        height: height - 280,
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        child: PagedListView<int, dynamic>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<dynamic>(
              animateTransitions: true,
              transitionDuration: const Duration(milliseconds: 500),
              itemBuilder: (context, item, index) {
                if ((index + 1) % 5 == 0) {
                  return Container(
                    height: itemHeight,
                    color: Theme.of(context).colorScheme.background,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: Container(
                        height: AD_HEIGHT,
                        width: width,
                        color: Theme.of(context).colorScheme.background,
                        child: const InlineAdaptiveAds(),
                      ),
                    ),
                  );
                }
                return TimelineRowWidget(item: item);
              }),
        ));
  }
}
