import 'package:get/get.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/comment_controller.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/ads/inline_ads.dart';
import 'package:machi_app/widgets/comment/comment_row_widget.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CommentWidget extends StatefulWidget {
  const CommentWidget({Key? key}) : super(key: key);

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  CommentController commentController = Get.find(tag: "comment");
  late AppLocalizations _i18n;

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;
    return PagedSliverList<int, dynamic>.separated(
      pagingController: commentController.pagingController,
      builderDelegate:
          PagedChildBuilderDelegate<dynamic>(noItemsFoundIndicatorBuilder: (_) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text(_i18n.translate("comment_none"))],
        );
      }, itemBuilder: (context, item, index) {
        return CommentRowWidget(
            item: item,
            onDelete: (item) {
              removeItem(item);
            });
      }),
      separatorBuilder: (BuildContext context, int index) {
        if ((index + 1) % 5 == 0) {
          return Padding(
            padding: const EdgeInsetsDirectional.only(top: 10, bottom: 10),
            child: Container(
              height: AD_HEIGHT,
              width: width,
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

  void removeItem(dynamic item) {
    final List<dynamic> updatedList =
        List.from(commentController.pagingController.itemList!);
    final int index = updatedList
        .indexWhere((element) => element.commentId == item.commentId);
    if (index != -1) {
      updatedList.removeAt(index);
      setState(() {
        commentController.pagingController.itemList = updatedList;
      });
    } else {
      /// @todo this is nested comments. Need to filter later.
      commentController.pagingController.refresh();
    }
  }
}
