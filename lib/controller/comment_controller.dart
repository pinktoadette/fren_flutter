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
  Rx<StoryComment> newComment = initial.obs;

  static const _pageSize = 20;

  // StoryComment? get newComment => _newComment.value;
  // set newComment(StoryComment? value) => _newComment.value = value;

  void currentNewComment(StoryComment addComment) {
    newComment = addComment.obs;
    newComment.refresh();
  }

  void onCurrentStoryComment(List<StoryComment> comment) {
    comments = comment.obs;
    comments.refresh();
  }

  Future<List<StoryComment>> fetchComments(int pageKey, String storyId) async {
    List<StoryComment> newItems =
        await _commentApi.getComments(pageKey, _pageSize, storyId);
    onCurrentStoryComment(newItems);
    comments.refresh();
    return newItems;
  }
}
