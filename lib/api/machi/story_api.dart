import 'package:flutter/cupertino.dart';
import 'package:fren_app/api/machi/auth_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/storyboard_controller.dart';
import 'package:fren_app/datas/storyboard.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:get/get.dart';

class StoryApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = PY_API;
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  Future<Storyboard> createStory(String title, String messageId) async {
    StoryboardController storyController = Get.find(tag: 'storyboard');
    try {
      String url = '${baseUri}storyboard/create';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response = await dio
          .post(url, data: {STORY_TITLE: title, STORY_MESSAGE_ID: messageId});

      Storyboard story = Storyboard.fromJson(response.data);
      storyController.addNewStoryboard(story);
      return story;
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }

  Future<Storyboard> addStory(
      int messageIndex, String messageId, String storyboardId) async {
    StoryboardController storyController = Get.find(tag: 'storyboard');
    try {
      String url = '${baseUri}storyboard/add';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response = await dio.post(url,
          data: {STORY_MESSAGE_ID: messageId, STORY_ID: storyboardId});

      Storyboard story = Storyboard.fromJson(response.data);
      storyController.updateStoryboard(messageIndex, story);
      return story;
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }

  Future<Storyboard> removeStory(
      int messageIndex, String messageId, String storyboardId) async {
    StoryboardController storyController = Get.find(tag: 'storyboard');
    try {
      String url = '${baseUri}storyboard/remove';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response = await dio.delete(url,
          data: {STORY_MESSAGE_ID: messageId, STORY_ID: storyboardId});

      Storyboard story = Storyboard.fromJson(response.data);
      storyController.updateStoryboard(messageIndex, story);
      return story;
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }

  Future<List<Storyboard>> getMyStories() async {
    StoryboardController storyController = Get.find(tag: 'storyboard');

    try {
      String url = '${baseUri}storyboard/my_stories';
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

  Future<Storyboard> getStoryById(String storyboardId) async {
    try {
      String url = '${baseUri}storyboard/story?storyId=$storyboardId';
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

  Future<String> updateSequence(List<Map<String, dynamic>> stories) async {
    try {
      String url = '${baseUri}storyboard/update';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response = await dio.post(url, data: stories);

      return response.data;
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }

  Future<String> publishStory(String storyId) async {
    try {
      String url = '${baseUri}storyboard/publish';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response = await dio.post(url, data: {STORY_ID: storyId});

      return response.data;
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
