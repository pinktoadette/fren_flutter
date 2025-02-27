import 'package:get/get.dart';
import 'package:machi_app/api/machi/comment_api.dart';
import 'package:machi_app/api/machi/timeline_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/comment_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/text_link_preview.dart';
import 'package:machi_app/widgets/like_widget.dart';
import 'package:machi_app/widgets/timeline/timeline_header.dart';

/// Used on comment widget that lists all comments
/// Used on page widget to create an illusion that new comments are posted
/// (This is done to reduce API calls and querying.)

class CommentRowWidget extends StatefulWidget {
  final StoryComment item;
  final bool hideReply;
  final Function(StoryComment data) onDelete;
  const CommentRowWidget(
      {Key? key,
      required this.item,
      required this.onDelete,
      this.hideReply = false})
      : super(key: key);

  @override
  State<CommentRowWidget> createState() => _CommentRowWidgetState();
}

class _CommentRowWidgetState extends State<CommentRowWidget> {
  final CommentController commentController = Get.find(tag: 'comment');
  bool toggleReplies = false;

  @override
  Widget build(BuildContext context) {
    AppLocalizations i18n = AppLocalizations.of(context);
    return Obx(() => Container(
        color:
            commentController.replyToComment?.commentId == widget.item.commentId
                ? APP_TERTIARY
                : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TimelineHeader(
              showAvatar: true,
              user: widget.item.user,
              showName: true,
              radius: 15,
              timestamp: widget.item.createdAt,
              showMenu: true,
              comment: widget.item,
              isChild: widget.hideReply,
              fontColor: APP_INVERSE_PRIMARY_COLOR,
              onDeleteComment: (action) {
                _onDeleteComment(context);
              },
            ),
            Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: textLinkPreview(
                  text: widget.item.comment,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: APP_INVERSE_PRIMARY_COLOR),
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(
                  width: 20,
                ),
                LikeItemWidget(
                  onLike: (val) {
                    _onLikePressed(widget.item.commentId!, val);
                  },
                  likes: widget.item.likes ?? 0,
                  mylikes: widget.item.mylikes ?? 0,
                  fontColor: APP_INVERSE_PRIMARY_COLOR,
                ),
                const SizedBox(
                  width: 10,
                ),
                if (widget.hideReply == false)
                  TextButton(
                      onPressed: () {
                        commentController.replyTo(widget.item);
                      },
                      child: Text(i18n.translate("comment_reply"),
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall!
                              .copyWith(color: APP_INVERSE_PRIMARY_COLOR))),
                const SizedBox(
                  width: 5,
                ),
                if (widget.item.response != null && widget.hideReply != true)
                  TextButton(
                      onPressed: () => setState(() {
                            toggleReplies = !toggleReplies;
                          }),
                      child: Text(
                          "${widget.item.response!.length} ${i18n.translate("comment_reply")} ",
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall!
                              .copyWith(color: APP_INVERSE_PRIMARY_COLOR))),
              ],
            ),
            const Divider(
              height: 1,
            ),
            if (widget.item.response != null && (toggleReplies == true))
              ...widget.item.response!
                  .map((ele) => Container(
                        padding: const EdgeInsets.only(left: 20),
                        color: Colors.black,
                        child: CommentRowWidget(
                            hideReply: true,
                            item: ele,
                            onDelete: (ele) {
                              widget.onDelete(ele);
                            }),
                      ))
                  .toList()
          ],
        )));
  }

  void _onDeleteComment(BuildContext context) async {
    final commentApi = CommentApi();
    AppLocalizations i18n = AppLocalizations.of(context);
    widget.onDelete(widget.item);

    try {
      await commentApi.deleteComment(widget.item.commentId!);
      Get.snackbar('DELETE', i18n.translate("comment_deleted"),
          snackPosition: SnackPosition.TOP,
          backgroundColor: APP_SUCCESS,
          colorText: Colors.black);
    } catch (err) {
      Get.snackbar('Error', i18n.translate("an_error_has_occurred"),
          snackPosition: SnackPosition.TOP, backgroundColor: APP_ERROR);
    }
  }

  void _onLikePressed(String commentId, bool like) async {
    final timelineApi = TimelineApi();
    try {
      await timelineApi.likeStoryMachi(
          "comment", widget.item.commentId!, like == true ? 1 : 0);
    } catch (err) {
      Get.snackbar('Error', err.toString(),
          snackPosition: SnackPosition.TOP, backgroundColor: APP_ERROR);
    }
  }
}
