import 'dart:developer';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:machi_app/api/machi/auth_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:machi_app/widgets/storyboard/my_edit/layout_edit.dart';

class StoryApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = "${PY_API}story/";
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
  }

  Future<Storyboard> addItemToStory(
      types.Message message, String storyboardId) async {
    StoryboardController storyController = Get.find(tag: 'storyboard');

    String url = '${baseUri}story';
    debugPrint("Requesting URL $url");
    final dio = await auth.getDio();
    final response = await dio.post(url, data: {STORY_ID: storyboardId});

    Storyboard story = Storyboard.fromJson(response.data);
    storyController.updateStoryboard(story);
    return story;
  }

  Future<String> deletStory(Story story) async {
    StoryboardController storyController = Get.find(tag: 'storyboard');

    String url = '${baseUri}story';
    debugPrint("Requesting URL $url");
    final dio = await auth.getDio();
    final response = await dio.delete(url, data: {STORY_ID: story.storyId});
    storyController.removeStory(story);
    return response.data;
  }

  Future<Story> getMyStories(String storyId) async {
    StoryboardController storyController = Get.find(tag: 'storyboard');
    String url = '${baseUri}story?storyId=$storyId';
    debugPrint("Requesting URL $url");

    final response = await auth.retryGetRequest(url);
    final data = response.data;

    Story story = Story.fromJson(data);
    storyController.setCurrentStory(story);
    return story;
  }

  Future<Storyboard> updateScriptSequence(
      List<Map<String, dynamic>> stories) async {
    StoryboardController storyController = Get.find(tag: 'storyboard');

    String url = '${baseUri}script/update_seq';
    debugPrint("Requesting URL $url");
    final dio = await auth.getDio();
    log(stories.toString());
    final response = await dio.post(url, data: stories);
    Storyboard story = Storyboard.fromJson(response.data);
    storyController.updateStoryboard(story);
    return story;
  }

  Future<Story> updateStory(
      {required Story story,
      String? title,
      String? photoUrl,
      String? summary,
      String? category,
      String? layout}) async {
    StoryboardController storyController = Get.find(tag: 'storyboard');

    String url = '${baseUri}story';
    debugPrint("Requesting URL $url");
    final dio = await auth.getDio();

    Map<String, dynamic> payload = {
      STORY_ID: story.storyId,
      STORY_PAGE_DIRECTION: story.pageDirection?.name,
      STORY_COVER_PAGES: story.pages?.isNotEmpty ?? false
          ? story.pages!
              .map((page) => {
                    STORY_PAGES_BACKGROUND: page.backgroundImageUrl,
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

    Story updatedStory = story.copyWith(
        layout: Layout.values
            .byName(layout ?? story.layout?.name ?? Layout.PUBLICATION.name),
        title: title ?? story.title,
        pageDirection: story.pageDirection,
        photoUrl: photoUrl ?? story.photoUrl);
    storyController.updateStory(story: updatedStory);
    return updatedStory;
  }

  Future<Map<String, dynamic>> publishStory(String storyId) async {
    String url = '${baseUri}publish';
    debugPrint("Requesting URL $url");
    final dio = await auth.getDio();
    final response = await dio.post(url, data: {STORY_ID: storyId});

    return response.data;
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
          reason: 'Failed to create quick story', fatal: true);
      rethrow;
    }
  }
}
