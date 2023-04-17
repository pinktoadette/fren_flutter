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

  Future<List<Storyboard>> addStory(String chatId, String storyboardId) async {
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

      return stories;
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }

  Future<List<Storyboard>> getMyStories() async {
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

      return stories;
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }
}
