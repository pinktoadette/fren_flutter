import 'dart:developer';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:machi_app/api/api_env.dart';
import 'package:machi_app/api/machi/auth_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

/// Handles all story response and requests in a story.
/// Storyboard -> Story -> Scripts.
class StoryApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = "${ApiConfiguration().getApiUrl()}story/";

  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  /// Creates a new STORY collection. Returns the entire storyboard
  Future<Story> createStory(
      {required String storyboardId,
      required String photoUrl,
      required String title,
      String? text}) async {
    StoryboardController storyController = Get.find(tag: 'storyboard');

    String url = '${baseUri}story';
    debugPrint("Requesting URL $url");
    try {
      final dio = await auth.getDio();
      final response = await dio.post(url, data: {
        STORYBOARD_ID: storyboardId,
        STORY_TITLE: title,
        STORY_PHOTO_URL: photoUrl,
        CHAT_TEXT: text ?? "",
      });

      Story story = Story.fromJson(response.data);
      storyController.addNewStory(story);
      return story;
    } catch (err, stack) {
      await FirebaseCrashlytics.instance.recordError(err, stack,
          reason: 'Failed to create api story', fatal: false);
      rethrow;
    }
  }

  Future<Storyboard> addItemToStory(
      types.Message message, String storyboardId) async {
    StoryboardController storyController = Get.find(tag: 'storyboard');

    String url = '${baseUri}story';
    debugPrint("Requesting URL $url");
    try {
      final dio = await auth.getDio();
      final response = await dio.post(url, data: {STORY_ID: storyboardId});

      Storyboard story = Storyboard.fromJson(response.data);
      storyController.updateStoryboard(story);
      return story;
    } catch (err, stack) {
      await FirebaseCrashlytics.instance.recordError(err, stack,
          reason: 'Failed to add item api story', fatal: false);
      rethrow;
    }
  }

  Future<String> deletStory(Story story) async {
    StoryboardController storyController = Get.find(tag: 'storyboard');

    String url = '${baseUri}story';
    debugPrint("Requesting URL $url");
    try {
      final dio = await auth.getDio();
      final response = await dio.delete(url, data: {STORY_ID: story.storyId});
      storyController.removeStory(story);
      return response.data;
    } catch (err, stack) {
      await FirebaseCrashlytics.instance.recordError(err, stack,
          reason: 'Failed to delete api story', fatal: false);
      rethrow;
    }
  }

  Future<Story> getMyStories(String storyId) async {
    StoryboardController storyController = Get.find(tag: 'storyboard');
    String url = '${baseUri}story?storyId=$storyId';
    debugPrint("Requesting URL $url");
    try {
      final response = await auth.retryGetRequest(url);
      final data = response.data;

      Story story = Story.fromJson(data);
      storyController.setCurrentStory(story);
      return story;
    } catch (err, stack) {
      await FirebaseCrashlytics.instance.recordError(err, stack,
          reason: 'Failed to get api story', fatal: false);
      rethrow;
    }
  }

  Future<Storyboard> updateScriptSequence(
      List<Map<String, dynamic>> stories) async {
    StoryboardController storyController = Get.find(tag: 'storyboard');

    String url = '${baseUri}script/update_seq';
    debugPrint("Requesting URL $url");
    try {
      final dio = await auth.getDio();
      log(stories.toString());
      final response = await dio.post(url, data: stories);
      Storyboard story = Storyboard.fromJson(response.data);
      storyController.updateStoryboard(story);
      return story;
    } catch (err, stack) {
      await FirebaseCrashlytics.instance.recordError(err, stack,
          reason: 'Failed to update sequence api story', fatal: false);
      rethrow;
    }
  }

  Future<Story> updateStory(
      {required Story story,
      String? title,
      String? photoUrl,
      String? summary,
      String? category,
      String? layout}) async {
    String url = '${baseUri}story';
    debugPrint("Requesting URL $url");
    try {
      final dio = await auth.getDio();
      Map<String, dynamic> payload = {
        STORY_ID: story.storyId,
        STORY_COVER_PAGES: story.pages?.isNotEmpty ?? false
            ? story.pages!
                .map((page) => {
                      STORY_PAGES_BACKGROUND: page.backgroundImageUrl,
                      STORY_PAGES_THUMBNAIL: page.thumbnail,
                      SCRIPT_PAGE_NUM: page.pageNum,
                      STORY_PAGES_ALPHA: page.backgroundAlpha
                    })
                .toList()
            : []
      };
      Map<String, dynamic> filter = {
        if (title != null) STORY_TITLE: title,
        if (category != null) STORY_CATEGORY: category,
        if (summary != null) STORY_SUMMARY: summary,
        if (photoUrl != null) STORY_PHOTO_URL: photoUrl,
        if (layout != null) STORY_LAYOUT: layout,
      };

      await dio.put(url, data: {...payload, ...filter});

      return story;
    } catch (err, stack) {
      await FirebaseCrashlytics.instance.recordError(err, stack,
          reason: 'Failed to update api story', fatal: false);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> publishStory(String storyId) async {
    String url = '${baseUri}publish';
    debugPrint("Requesting URL $url");
    try {
      final dio = await auth.getDio();
      final response = await dio.post(url, data: {STORY_ID: storyId});
      return response.data;
    } catch (err, stack) {
      await FirebaseCrashlytics.instance.recordError(err, stack,
          reason: 'Failed to public api story', fatal: false);
      rethrow;
    }
  }

  Future<Storyboard> quickStory(String text) async {
    try {
      String url = '${baseUri}quick';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response = await dio.post(url, data: {SCRIPT_TEXT: text});
      Storyboard story = Storyboard.fromJson(response.data);

      return story;
    } catch (err, stack) {
      await FirebaseCrashlytics.instance.recordError(err, stack,
          reason: 'Failed to create quick api story', fatal: true);
      rethrow;
    }
  }
}
