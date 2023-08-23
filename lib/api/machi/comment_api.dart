import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:machi_app/api/machi/auth_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/story.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;

class CommentApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = '${PY_API}story/';
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  Future<StoryComment> postComment(
      {required String storyId,
      required String comment,
      StoryComment? replyToComment,
      CancelToken? cancelToken}) async {
    String url = '${baseUri}comment';
    debugPrint("Requesting URL $url");
    try {
      final dio = await auth.getDio();
      final response = await dio.post(url,
          data: {
            STORY_ID: storyId,
            STORY_COMMENT: comment,
            COMMENT_REPLY_TO_ID: replyToComment?.commentId ?? "",
            COMMENT_REPLY_TO_USER_ID: replyToComment?.user.userId ?? ""
          },
          cancelToken: cancelToken);
      StoryComment storyComment = StoryComment.fromDocument(response.data);
      return storyComment;
    } catch (err, stack) {
      await FirebaseCrashlytics.instance.recordError(err, stack,
          reason: 'Failed to post api comment', fatal: false);
      rethrow;
    }
  }

  Future<List<StoryComment>> getComments(
      int page, int limit, String storyId, CancelToken? cancelToken) async {
    String url = '${baseUri}comment?storyId=$storyId&limit=$limit&page=$page';
    debugPrint("Requesting URL $url");
    try {
      final response =
          await auth.retryGetRequest(url, cancelToken: cancelToken);
      final data = response.data;

      List<StoryComment> comments = [];
      for (var res in data) {
        StoryComment c = StoryComment.fromDocument(res);
        comments.add(c);
      }
      return comments;
    } catch (err, stack) {
      await FirebaseCrashlytics.instance.recordError(err, stack,
          reason: 'Failed to get api comment', fatal: false);
      rethrow;
    }
  }

  Future<String> deleteComment(String commentId) async {
    String url = '${baseUri}comment';
    debugPrint("Requesting URL $url");
    try {
      final dio = await auth.getDio();
      final response = await dio.delete(url, data: {COMMENT_ID: commentId});
      return response.data;
    } catch (err, stack) {
      await FirebaseCrashlytics.instance.recordError(err, stack,
          reason: 'Failed to delete api comment', fatal: false);
      rethrow;
    }
  }
}
