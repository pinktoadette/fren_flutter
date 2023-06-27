import 'package:flutter/cupertino.dart';
import 'package:machi_app/api/machi/auth_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:get/get.dart';

class StoryboardApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = "${PY_API}storyboard/";
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  Future<Storyboard> getStoryboardById(String storyboardId) async {
    try {
      String url = '${baseUri}board?storyboardId=$storyboardId';
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
      {String? text,
      String? image,
      String? category,
      String? characterId,
      String? character,
      String? messageId}) async {
    StoryboardController storyController = Get.find(tag: 'storyboard');
    try {
      String url = '${baseUri}board';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response = await dio.post(url, data: {
        CHAT_TEXT: text ?? "",
        CHAT_IMAGE: image ?? "",
        STORY_CATEGORY: category ?? "",
        STORY_BITS: {
          SCRIPT_SPEAKER_USER_ID: characterId,
          SCRIPT_SPEAKER_NAME: character,
          SCRIPT_PAGE_NUM: 1,
          SCRIPT_TYPE: text != null ? 'text' : 'image'
        }
      });

      Storyboard story = Storyboard.fromJson(response.data);
      storyController.addNewStoryboard(story);
      return story;
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
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
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }

  Future<List<Storyboard>> getMyStoryboards({String? statusFilter}) async {
    try {
      String url =
          '${baseUri}my_storyboards${statusFilter != null ? "?status=$statusFilter" : ""}';
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

  Future<Storyboard> updateStoryboard(
      {required String storyboardId,
      required String title,
      String? photoUrl}) async {
    StoryboardController storyController = Get.find(tag: 'storyboard');
    try {
      String url = '${baseUri}board';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response = await dio.put(url, data: {
        STORYBOARD_ID: storyboardId,
        STORYBOARD_TITLE: title,
        STORYBOARD_PHOTO_URL: photoUrl ?? "",
      });

      Storyboard story = Storyboard.fromJson(response.data);
      storyController.updateStoryboard(story);
      storyController.setCurrentBoard(story);
      return story;
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
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
      throw error.toString();
    }
  }

  Future<List<dynamic>> getContributors({required String storyboardId}) async {
    try {
      String url = '${baseUri}contributors?storyboardId=$storyboardId';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response = await dio.get(url);
      return response.data['characters'];
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }
}
