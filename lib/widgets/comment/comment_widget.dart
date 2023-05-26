import 'package:machi_app/api/machi/comment_api.dart';
import 'package:machi_app/datas/story.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/widgets/timeline/timeline_header.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CommentWidget extends StatefulWidget {
  final Story story;
  const CommentWidget({Key? key, required this.story}) : super(key: key);

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  final _commentApi = CommentApi();
  static const _pageSize = 20;

  final PagingController<int, dynamic> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      List<StoryComment> newItems = await _commentApi.getComments(
          pageKey, _pageSize, widget.story.storyId);
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
    double height = MediaQuery.of(context).size.height;
    return PagedSliverList<int, dynamic>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<dynamic>(
          itemBuilder: (context, item, index) {
        return _rowGenerator(item);
      }),
    );
  }

  Widget _rowGenerator(StoryComment item) {
    return Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TimelineHeader(showAvatar: true, user: item.user),
            Text(item.comment),
            const SizedBox(height: 20),
            const Divider()
          ],
        ));
  }
}
