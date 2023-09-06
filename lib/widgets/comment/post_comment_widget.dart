import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/machi/comment_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/comment_controller.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/controller/timeline_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/helpers/truncate_text.dart';
import 'package:machi_app/widgets/button/loading_button.dart';

class PostCommentWidget extends StatefulWidget {
  const PostCommentWidget({Key? key}) : super(key: key);

  @override
  State<PostCommentWidget> createState() => _PostCommentWidgetState();
}

class _PostCommentWidgetState extends State<PostCommentWidget> {
  final CommentController commentController = Get.find(tag: 'comment');
  final _commentController = TextEditingController();
  late AppLocalizations _i18n;
  String _comment = "";
  bool _canType = true;
  bool _isLoading = false;
  double padding = 20;
  late MediaQueryData query;

  final _cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _commentController.dispose();
    _cancelToken.cancel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _i18n = AppLocalizations.of(context);
    query = MediaQuery.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(
          padding,
          0,
          padding,
          query.viewInsets.bottom + padding / 2,
        ),
        width: query.size.width,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24), topRight: Radius.circular(24))),
        child: Stack(children: [
          Obx(() => commentController.replyToComment?.commentId != null
              ? TextButton.icon(
                  style: TextButton.styleFrom(
                      iconColor: APP_INVERSE_PRIMARY_COLOR,
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      alignment: Alignment.centerLeft),
                  label: Text(
                    "${_i18n.translate("comment_reply_to")} @${truncateText(maxLength: 30, text: commentController.replyToComment?.user.username ?? "")}",
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall!
                        .copyWith(color: APP_INVERSE_PRIMARY_COLOR),
                    overflow: TextOverflow.fade,
                  ),
                  icon: const Icon(Icons.cancel, size: 14),
                  onPressed: () {
                    commentController.clearReplyTo();
                  },
                )
              : const SizedBox(
                  height: 20,
                )),
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            padding: EdgeInsets.only(
                top: commentController.replyToComment != null ? 20 : 10),
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: 50,
                      maxHeight: 100.0,
                    ),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                              child: TextFormField(
                            onTapOutside: (_) =>
                                {FocusManager.instance.primaryFocus?.unfocus()},
                            onChanged: (String value) {
                              setState(() {
                                _comment = value;
                              });
                            },
                            textCapitalization: TextCapitalization.sentences,
                            autocorrect: true,
                            enableSuggestions: true,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(color: APP_INVERSE_PRIMARY_COLOR),
                            controller: _commentController,
                            maxLines: null,
                            decoration: InputDecoration(
                              suffixIconColor: APP_INVERSE_PRIMARY_COLOR,
                              fillColor: Colors.transparent,
                              hintText: _i18n.translate("comment_leave"),
                              hintStyle: const TextStyle(
                                  color: APP_INVERSE_PRIMARY_COLOR,
                                  fontSize: 14),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                            ),
                            validator: (value) {
                              if ((value == null) || (value == "")) {
                                return _i18n
                                    .translate("validation_1_character");
                              }
                              return null;
                            },
                          )),
                          if (_comment.isNotEmpty)
                            IconButton(
                              icon: _isLoading
                                  ? loadingButton(
                                      size: 16,
                                      color: APP_INVERSE_PRIMARY_COLOR)
                                  : const Icon(
                                      Iconsax.send_2,
                                      size: 24,
                                      color: APP_INVERSE_PRIMARY_COLOR,
                                    ),
                              onPressed: () {
                                if (_canType == false) {
                                  Get.snackbar(
                                      "Ayo", _i18n.translate("post_too_fast"),
                                      snackPosition: SnackPosition.TOP,
                                      backgroundColor: APP_TERTIARY,
                                      colorText: Colors.white);
                                } else {
                                  _postComment();
                                  Timer(
                                      const Duration(seconds: 10),
                                      () => setState(() {
                                            _canType = true;
                                          }));
                                }
                              },
                            ),
                        ]))),
          )
        ]));
  }

  void _postComment() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _canType = false;
      _isLoading = true;
    });

    StoryboardController storyboardController = Get.find(tag: 'storyboard');
    final commentApi = CommentApi();
    try {
      StoryComment newComment = await commentApi.postComment(
          storyId: storyboardController.currentStory.storyId,
          comment: _comment,
          replyToComment: commentController.replyToComment?.commentId == null
              ? null
              : commentController.replyToComment,
          cancelToken: _cancelToken);
      _formatComment(newComment);
      Get.snackbar(_i18n.translate("success"), _i18n.translate("posted"),
          snackPosition: SnackPosition.TOP,
          backgroundColor: APP_SUCCESS,
          colorText: Colors.black);
      _commentController.clear();
      commentController.clearReplyTo();
      FocusManager.instance.primaryFocus?.unfocus();
    } on DioException catch (err, s) {
      Get.snackbar(
        _i18n.translate("error"),
        err.response?.data["message"] ?? "Sorry, got an error 😕",
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_ERROR,
      );
      await FirebaseCrashlytics.instance
          .recordError(err, s, reason: 'Cannot post comment', fatal: false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _formatComment(StoryComment value) {
    StoryboardController storyboardController = Get.find(tag: 'storyboard');
    TimelineController timelineController = Get.find(tag: 'timeline');
    StoryComment? replyTo = commentController.replyToComment;
    if (replyTo?.commentId != null) {
      replyTo?.response!.add(value);
      commentController.updateItem(replyTo!);
      return;
    }

    commentController.addItem(value);

    Storyboard currentBoard = storyboardController.currentStoryboard;
    Story currentStory = storyboardController.currentStory;
    Story update = currentStory.copyWith(
        commentCount: (currentStory.commentCount ?? 0) + 1);
    timelineController.updateStoryboard(
        storyboard: currentBoard, updateStory: update);
  }
}
