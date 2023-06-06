import 'package:flutter/material.dart';
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

  RxList<StoryComment> comments = <StoryComment>[].obs;
  // ignore: prefer_final_fields
  Rx<StoryComment> _replyToComment = initial.obs;

  StoryComment get replyToComment => _replyToComment.value;
  set replyToComment(StoryComment value) => _replyToComment.value = value;

  void clearReplyTo() {
    replyToComment = initial;
  }
}
