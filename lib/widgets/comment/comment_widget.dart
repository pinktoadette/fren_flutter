import 'package:machi_app/api/machi/comment_api.dart';
import 'package:machi_app/datas/story.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/comment/comment_row_widget.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CommentWidget extends StatefulWidget {
  final Story story;
  final StoryComment? newComment;
  const CommentWidget({Key? key, required this.story, this.newComment})
      : super(key: key);

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  final _commentApi = CommentApi();

  static const _pageSize = 20;
  late AppLocalizations _i18n;

  final PagingController<int, dynamic> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    super.initState();

    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
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
    _i18n = AppLocalizations.of(context);

    return PagedSliverList<int, dynamic>(
      pagingController: _pagingController,
      builderDelegate:
          PagedChildBuilderDelegate<dynamic>(noItemsFoundIndicatorBuilder: (_) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text(_i18n.translate("comment_none"))],
        );
      }, itemBuilder: (context, item, index) {
        return CommentRowWidget(item: item);
      }),
    );
  }
}
