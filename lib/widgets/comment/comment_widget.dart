import 'package:get/get.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/comment_controller.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/ads/inline_ads.dart';
import 'package:machi_app/widgets/comment/comment_row_widget.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CommentWidget extends StatelessWidget {
  const CommentWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CommentController commentController = Get.find(tag: "comment");

    AppLocalizations _i18n = AppLocalizations.of(context);
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
              commentController.removeItem(item);
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
}
