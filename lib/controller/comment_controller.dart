import 'package:flutter/material.dart';
import 'package:machi_app/api/machi/comment_api.dart';
import 'package:machi_app/datas/story.dart';
import 'package:get/get.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/date_format.dart';
import 'package:machi_app/models/user_model.dart';

StoryComment initial = StoryComment(
  comment: '',
  createdAt: getDateTimeEpoch(),
  updatedAt: getDateTimeEpoch(),
  user: StoryUser(
      userId: UserModel().user.userId,
      photoUrl: UserModel().user.userProfilePhoto,
      username: UserModel().user.username),
);

class CommentController extends GetxController {
  ScrollController controller = ScrollController();

  final _commentApi = CommentApi();
  RxList<StoryComment> comments = <StoryComment>[].obs;
  Rx<StoryComment> _replyToComment = initial.obs;

  StoryComment get replyToComment => _replyToComment.value;
  set replyToComment(StoryComment value) => _replyToComment.value = value;

  void clearReplyTo() {
    replyToComment = initial;
  }
}
