import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:machi_app/api/machi/auth_api.dart';
import 'package:machi_app/api/machi/timeline_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:get/get.dart';

class StoryApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = PY_API;
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  Future<Storyboard> createStory(
      String title, String category, String messageId) async {
    StoryboardController storyController = Get.find(tag: 'storyboard');
    try {
      String url = '${baseUri}story/story';
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

  Future<Storyboard> addStory(
      int messageIndex, String messageId, String storyboardId) async {
    StoryboardController storyController = Get.find(tag: 'storyboard');
    try {
      String url = '${baseUri}story/story';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response = await dio.post(url, data: {STORY_ID: storyboardId});

      Storyboard story = Storyboard.fromJson(response.data);
      storyController.updateStoryboard(story);
      return story;
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }

  Future<Storyboard> removeStory(String messageId, String storyboardId) async {
    StoryboardController storyController = Get.find(tag: 'storyboard');
    try {
      String url = '${baseUri}story/story';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response = await dio.delete(url, data: {STORY_ID: storyboardId});

      Storyboard story = Storyboard.fromJson(response.data);
      storyController.updateStoryboard(story);
      return story;
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }

  Future<List<Storyboard>> getMyStories() async {
    StoryboardController storyController = Get.find(tag: 'storyboard');

    try {
      String url = '${baseUri}story/story';
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

  Future<Storyboard> updateScriptSequence(
      List<Map<String, dynamic>> stories) async {
    StoryboardController storyController = Get.find(tag: 'storyboard');

    try {
      String url = '${baseUri}script/update_seq';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      log(stories.toString());
      final response = await dio.post(url, data: stories);
      Storyboard story = Storyboard.fromJson(response.data);
      storyController.updateStoryboard(story);
      return story;
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }

  Future<Storyboard> updateStory(
      String storyId, Map<String, dynamic> titleCatUpdate) async {
    StoryboardController storyController = Get.find(tag: 'storyboard');

    try {
      String url = '${baseUri}story/story';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response =
          await dio.put(url, data: {...titleCatUpdate, STORY_ID: storyId});
      Storyboard story = Storyboard.fromJson(response.data);
      storyController.updateStoryboard(story);
      return story;
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }

  Future<String> publishStory(String storyId) async {
    final _timelineApi = TimelineApi();
    try {
      String url = '${baseUri}story/publish';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response = await dio.post(url, data: {STORY_ID: storyId});
      await _timelineApi.getTimeline();
      return response.data;
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }
}
