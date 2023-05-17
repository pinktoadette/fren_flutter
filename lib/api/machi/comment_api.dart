import 'package:flutter/cupertino.dart';
import 'package:machi_app/api/machi/auth_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:get/get.dart';

class CommentApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = PY_API;
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  /// Move this to comments
  Future<Storyboard> updateStoryboard(
      String storyboardId, Map<String, dynamic> titleCatUpdate) async {
    StoryboardController storyController = Get.find(tag: 'storyboard');

    try {
      String url = '${baseUri}storyboard/board';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response =
          await dio.put(url, data: {...titleCatUpdate, STORY_ID: storyboardId});
      Storyboard story = Storyboard.fromJson(response.data);
      storyController.updateStoryboard(story);
      return story;
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }

  Future<String> postComment(String storyId, String comment) async {
    try {
      String url = '${baseUri}storyboard/comment';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response = await dio
          .post(url, data: {STORY_ID: storyId, STORY_COMMENT: comment});

      return response.data;
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }

  Future<List<StoryComment>> getComments(
      int page, int limit, String storyId) async {
    try {
      String url = '${baseUri}storyboard/comment?storyId=$storyId';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response = await dio.get(url, data: {LIMIT: limit, "offset": page});

      List<StoryComment> comments = [];
      for (var res in response.data) {
        StoryComment c = StoryComment.fromDocument(res);
        comments.add(c);
      }
      return comments;
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }
}
