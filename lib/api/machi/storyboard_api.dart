import 'package:flutter/cupertino.dart';
import 'package:machi_app/api/machi/auth_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:get/get.dart';

class StoryboardApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = PY_API;
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  Future<Storyboard> getStoryboardById(String storyboardId) async {
    try {
      String url = '${baseUri}storyboard/board?storyId=$storyboardId';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response = await dio.get(url);

      Storyboard story = Storyboard.fromJson(response.data);
      return story;
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }

  Future<Storyboard> createStoryboard(
      String title, String category, String messageId) async {
    StoryboardController storyController = Get.find(tag: 'storyboard');
    try {
      String url = '${baseUri}storyboard/board';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response = await dio.post(url, data: {
        STORY_TITLE: title,
        STORY_CATEGORY: category,
      });

      Storyboard story = Storyboard.fromJson(response.data);
      storyController.addNewStoryboard(story);
      return story;
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }

  Future<Storyboard> removeStoryboard(
      String messageId, String storyboardId) async {
    StoryboardController storyController = Get.find(tag: 'storyboard');
    try {
      String url = '${baseUri}storyboard/board';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response =
          await dio.delete(url, data: {STORYBOARD_ID: storyboardId});

      Storyboard story = Storyboard.fromJson(response.data);
      storyController.updateStoryboard(story);
      return story;
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }

  Future<List<Storyboard>> getMyStoryboards() async {
    StoryboardController storyController = Get.find(tag: 'storyboard');

    try {
      String url = '${baseUri}storyboard/my_storyboards';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response = await dio.get(url);

      List<Storyboard> stories = [];
      for (var story in response.data) {
        Storyboard s = Storyboard.fromJson(story);
        stories.add(s);
      }
      storyController.myStories(stories);
      return stories;
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }

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
