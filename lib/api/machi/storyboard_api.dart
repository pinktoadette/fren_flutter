import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:machi_app/api/api_env.dart';
import 'package:machi_app/api/machi/auth_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:get/get.dart';

/// Handles all storyboard response and requests in a story.
/// Storyboard -> Story -> Scripts.
class StoryboardApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = "${ApiConfiguration().getApiUrl()}storyboard/";
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  Future<Storyboard> getStoryboardById(String storyboardId) async {
    try {
      String url = '${baseUri}board?storyboardId=$storyboardId';
      debugPrint("Requesting URL $url");
      final response = await auth.retryGetRequest(url);
      final data = response.data;

      Storyboard story = Storyboard.fromJson(data);
      return story;
    } catch (err, stack) {
      await FirebaseCrashlytics.instance.recordError(err, stack,
          reason: 'Failed to get api storyboard', fatal: false);
      rethrow;
    }
  }

  Future<Storyboard> createStoryboard(
      {String? text,
      String? title,
      String? image,
      String? summary,
      String? category,
      String? characterId,
      String? character,
      String? messageId}) async {
    StoryboardController storyController = Get.find(tag: 'storyboard');
    try {
      String url = '${baseUri}board';
      debugPrint("Requesting URL $url");
      Map<String, dynamic> requestData = {
        CHAT_TEXT: text ?? "",
        CHAT_IMAGE: image ?? "",
        STORY_BITS: {
          SCRIPT_SPEAKER_USER_ID: characterId,
          SCRIPT_SPEAKER_NAME: character,
          SCRIPT_PAGE_NUM: 1,
          SCRIPT_TYPE: text != null ? 'text' : 'image',
        },
      };

      if (summary != null) {
        requestData[STORYBOARD_SUMMARY] = summary;
      }

      if (title != null) {
        requestData[STORYBOARD_TITLE] = title;
      }

      if (category != null) {
        requestData[STORY_CATEGORY] = category;
      }

      final dio = await auth.getDio();
      final response = await dio.post(url, data: requestData);

      Storyboard story = Storyboard.fromJson(response.data);
      storyController.addNewStoryboard(story);
      return story;
    } catch (err, stack) {
      await FirebaseCrashlytics.instance.recordError(err, stack,
          reason: 'Failed to create api storyboard', fatal: false);
      rethrow;
    }
  }

  Future<String> deleteBoard(Storyboard storyboard) async {
    StoryboardController storyController = Get.find(tag: 'storyboard');
    try {
      String url = '${baseUri}board';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response =
          await dio.delete(url, data: {STORYBOARD_ID: storyboard.storyboardId});
      storyController.removeStoryboardfromList(storyboard);
      return response.data;
    } catch (err, stack) {
      await FirebaseCrashlytics.instance.recordError(err, stack,
          reason: 'Failed to delete api storyboard', fatal: false);
      rethrow;
    }
  }

  Future<List<Storyboard>> getMyStoryboards(
      {String? statusFilter, CancelToken? cancelToken}) async {
    try {
      String url =
          '${baseUri}my_storyboards${statusFilter != null ? "?status=$statusFilter" : ""}';
      debugPrint("Requesting URL $url");
      final response =
          await auth.retryGetRequest(url, cancelToken: cancelToken);
      final data = response.data;

      List<Storyboard> stories = [];
      for (var story in data) {
        Storyboard s = Storyboard.fromJson(story);
        stories.add(s);
      }
      return stories;
    } catch (err, stack) {
      await FirebaseCrashlytics.instance.recordError(err, stack,
          reason: 'Failed to get api my storyboard', fatal: false);
      rethrow;
    }
  }

  Future<Storyboard> updateStoryboard({
    required String storyboardId,
    required String title,
    required String category,
    String? photoUrl,
  }) async {
    StoryboardController storyController = Get.find(tag: 'storyboard');
    try {
      String url = '${baseUri}board';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response = await dio.put(url, data: {
        STORYBOARD_ID: storyboardId,
        STORYBOARD_TITLE: title,
        STORYBOARD_PHOTO_URL: photoUrl ?? "",
        STORYBOARD_CATEGORY: category
      });

      Storyboard story = Storyboard.fromJson(response.data);
      storyController.updateStoryboard(story);
      storyController.setCurrentBoard(story);
      return story;
    } catch (err, stack) {
      await FirebaseCrashlytics.instance.recordError(err, stack,
          reason: 'Failed to update api storyboard', fatal: false);
      rethrow;
    }
  }

  Future<Storyboard> publishAll({required String storyboardId}) async {
    StoryboardController storyController = Get.find(tag: 'storyboard');
    try {
      String url = '${baseUri}publish_all';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response = await dio.post(url, data: {
        STORYBOARD_ID: storyboardId,
      });

      Storyboard story = Storyboard.fromJson(response.data);
      storyController.updateStoryboard(story);
      return story;
    } catch (error) {
      debugPrint(error.toString());
      rethrow;
    }
  }

  Future<List<dynamic>> getContributors(
      {required String storyboardId, CancelToken? cancelToken}) async {
    try {
      String url = '${baseUri}contributors?storyboardId=$storyboardId';
      debugPrint("Requesting URL $url");
      final response =
          await auth.retryGetRequest(url, cancelToken: cancelToken);
      final data = response.data;
      return data['characters'];
    } catch (err, stack) {
      await FirebaseCrashlytics.instance.recordError(err, stack,
          reason: 'Failed to get contributors to storyboard', fatal: false);
      rethrow;
    }
  }
}
