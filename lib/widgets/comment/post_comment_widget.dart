import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/machi/comment_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/comment_controller.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/helpers/truncate_text.dart';

// ignore: must_be_immutable
class PostCommentWidget extends StatelessWidget {
  PostCommentWidget({Key? key}) : super(key: key);
  final CommentController commentController = Get.find(tag: 'comment');
  final _commentController = TextEditingController();
  late AppLocalizations _i18n;

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;

    return Container(
        padding:
            const EdgeInsets.only(bottom: 10, left: 20, right: 20, top: 10),
        width: width,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24), topRight: Radius.circular(24))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => commentController.replyToComment.commentId != null
                ? TextButton.icon(
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.centerLeft),
                    label: Text(
                      "${_i18n.translate("comment_reply_to")} @${truncateText(maxLength: 30, text: commentController.replyToComment.user.username)}",
                      style: Theme.of(context).textTheme.labelSmall,
                      overflow: TextOverflow.fade,
                    ),
                    icon: const Icon(Icons.cancel, size: 14),
                    onPressed: () {
                      commentController.clearReplyTo();
                    },
                  )
                : const SizedBox.shrink()),
            ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 60,
                  maxHeight: 350.0,
                ),
                child: TextFormField(
                  style: Theme.of(context).textTheme.bodyMedium,
                  controller: _commentController,
                  maxLines: null,
                  // maxLength: 250,
                  decoration: InputDecoration(
                    fillColor: Colors.transparent,
                    hintText: _i18n.translate("comment_leave"),
                    hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Iconsax.send_2,
                        size: 24,
                      ),
                      onPressed: () {
                        if (_commentController.text.isEmpty) {
                          return;
                        } else {
                          _postComment();
                        }
                      },
                    ),
                  ),
                  validator: (value) {
                    if ((value == null) || (value == "")) {
                      return _i18n.translate("validation_1_character");
                    }
                    return null;
                  },
                )),
          ],
        ));
  }

  void _postComment() async {
    StoryboardController storyboardController = Get.find(tag: 'storyboard');
    final _commentApi = CommentApi();
    try {
      StoryComment newComment = await _commentApi.postComment(
          storyId: storyboardController.currentStory.storyId,
          comment: _commentController.text,
          replyToComment: commentController.replyToComment.commentId == null
              ? null
              : commentController.replyToComment);
      _formatComment(newComment);
      Get.snackbar(_i18n.translate("success"), _i18n.translate("posted"),
          snackPosition: SnackPosition.TOP,
          backgroundColor: APP_SUCCESS,
          colorText: Colors.black);
      _commentController.clear();
      commentController.clearReplyTo();
      FocusManager.instance.primaryFocus?.unfocus();
    } catch (err, s) {
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
      await FirebaseCrashlytics.instance
          .recordError(err, s, reason: 'Cannot post comment', fatal: true);
    }
  }

  void _formatComment(StoryComment value) {
    CommentController commentController = Get.find(tag: 'comment');
    StoryComment? replyTo = commentController.replyToComment;
    if (replyTo.commentId != null) {
      replyTo.response!.add(value);
      commentController.updateItem(replyTo);
      return;
    }

    commentController.addItem(value);
  }
}
