import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/api/machi/comment_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/comment_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/helpers/truncate_text.dart';

class PostCommentWidget extends StatefulWidget {
  final Story story;
  final Function(dynamic data) notifyParent;
  const PostCommentWidget(
      {Key? key, required this.story, required this.notifyParent})
      : super(key: key);

  @override
  _PostCommentWidgetState createState() => _PostCommentWidgetState();
}

class _PostCommentWidgetState extends State<PostCommentWidget> {
  late AppLocalizations _i18n;
  CommentController commentController = Get.find(tag: 'comment');

  final _commentController = TextEditingController();
  final _commentApi = CommentApi();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
          width: width,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              border: Border.all(color: Theme.of(context).colorScheme.tertiary),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24), topRight: Radius.circular(24))),
          child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: 80,
                maxHeight: 300.0,
              ),
              child: TextFormField(
                controller: _commentController,
                maxLines: null,
                // maxLength: 250,
                decoration: InputDecoration(
                  hintText: _i18n.translate("comment_leave"),
                  hintStyle:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Iconsax.send_1),
                    onPressed: () {
                      _postComment();
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
        ),
        Positioned(
            bottom: 0,
            left: 5,
            child: Obx(() => Align(
                  widthFactor: 1,
                  child: TextButton.icon(
                    label: Text(
                      commentController.replyToComment.commentId != null
                          ? "Reply @${truncateText(30, commentController.replyToComment.user.username)}"
                          : "",
                      style: Theme.of(context).textTheme.labelSmall,
                      overflow: TextOverflow.fade,
                    ),
                    icon: commentController.replyToComment.commentId != null
                        ? const Icon(Icons.cancel, size: 14)
                        : const SizedBox.shrink(),
                    onPressed: () {
                      commentController.clearReplyTo();
                    },
                  ),
                ))),
      ],
    );
  }

  void _postComment() async {
    try {
      StoryComment newComment = await _commentApi.postComment(
          storyId: widget.story.storyId,
          comment: _commentController.text,
          replyToComment: commentController.replyToComment);
      widget.notifyParent(newComment);
      Get.snackbar(
        _i18n.translate("success"),
        _i18n.translate("posted"),
        snackPosition: SnackPosition.TOP,
        backgroundColor: APP_SUCCESS,
      );
      _commentController.clear();
      FocusManager.instance.primaryFocus?.unfocus();
    } catch (e) {
      Get.snackbar(
        _i18n.translate("error"),
        _i18n.translate("an_error_has_occurred"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: APP_ERROR,
      );
    }
  }
}
