import 'package:get/get.dart';
import 'package:machi_app/api/machi/comment_api.dart';
import 'package:machi_app/api/machi/timeline_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/story.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/widgets/like_widget.dart';
import 'package:machi_app/widgets/report_list.dart';
import 'package:machi_app/widgets/timeline/timeline_header.dart';

/// Used on comment widget that lists all comments
/// Used on page widget to create an illusion that new comments are posted
/// (This is done to reduce API calls and querying.)
class CommentRowWidget extends StatelessWidget {
  final StoryComment item;
  final Function(StoryComment data) onDelete;
  const CommentRowWidget(
      {super.key, required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    AppLocalizations _i18n = AppLocalizations.of(context);
    return Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TimelineHeader(
              showAvatar: true,
              user: item.user,
              showName: true,
              radius: 15,
              timestamp: item.createdAt,
              showMenu: true,
              comment: item,
              onDeleteComment: (action) {
                _onDeleteComment(context);
              },
            ),
            Text(
              item.comment,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () {},
                    child: Text(_i18n.translate("comment_reply"),
                        style: Theme.of(context).textTheme.labelSmall)),
                const SizedBox(
                  width: 5,
                ),
                LikeItemWidget(
                    onLike: (val) {
                      _onLikePressed(item.commentId!, val);
                    },
                    likes: item.likes ?? 0,
                    mylikes: item.mylikes ?? 0)
              ],
            ),
            const Divider()
          ],
        ));
  }

  void _onDeleteComment(BuildContext context) async {
    final _commentApi = CommentApi();
    AppLocalizations _i18n = AppLocalizations.of(context);
    onDelete(item);

    try {
      await _commentApi.deleteComment(item.commentId!);
      Get.snackbar('DELETE', _i18n.translate("comment_deleted"),
          snackPosition: SnackPosition.TOP, backgroundColor: APP_SUCCESS);
    } catch (err) {
      Get.snackbar('Error', _i18n.translate("an_error_has_occurred"),
          snackPosition: SnackPosition.BOTTOM, backgroundColor: APP_ERROR);
    }
  }

  void _onLikePressed(String commentId, bool like) async {
    final _timelineApi = TimelineApi();
    try {
      await _timelineApi.likeStoryMachi(
          "comment", item.commentId!, like == true ? 1 : 0);
    } catch (err) {
      Get.snackbar('Error', err.toString(),
          snackPosition: SnackPosition.BOTTOM, backgroundColor: APP_ERROR);
    }
  }
}
