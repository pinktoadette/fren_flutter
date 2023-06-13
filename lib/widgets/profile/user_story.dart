import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:machi_app/api/machi/timeline_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/ads/inline_ads.dart';
import 'package:machi_app/widgets/animations/loader.dart';
import 'package:machi_app/widgets/storyboard/storyboard_item_widget.dart';

class UserStory extends StatefulWidget {
  final String userId;

  const UserStory({Key? key, required this.userId}) : super(key: key);

  @override
  _UserStoryState createState() => _UserStoryState();
}

class _UserStoryState extends State<UserStory> {
  final _timelineApi = TimelineApi();
  final PagingController<int, Storyboard> _pagingController =
      PagingController(firstPageKey: 0);

  List<Storyboard> storyboards = [];
  static const int _pageSize = 30;

  @override
  void initState() {
    super.initState();
    _fetchPage(0);
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      List<Storyboard> newItems =
          await _timelineApi.getTimelineByPageUserId(widget.userId);
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
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PagedListView<int, Storyboard>.separated(
      pagingController: _pagingController,
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      builderDelegate: PagedChildBuilderDelegate<Storyboard>(
          firstPageProgressIndicatorBuilder: (_) => const Frankloader(),
          newPageProgressIndicatorBuilder: (_) => const Frankloader(),
          itemBuilder: (context, item, index) {
            return StoryboardItemWidget(item: item);
          }),
      separatorBuilder: (BuildContext context, int index) {
        if ((index + 1) % 4 == 0) {
          return Padding(
            padding: const EdgeInsetsDirectional.only(top: 10, bottom: 10),
            child: Container(
              height: AD_HEIGHT,
              width: size.width,
              color: Theme.of(context).colorScheme.background,
              child: const InlineAdaptiveAds(),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
