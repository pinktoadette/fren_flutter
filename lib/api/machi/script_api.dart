import 'package:flutter/cupertino.dart';
import 'package:machi_app/api/machi/auth_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/script.dart';
import 'package:machi_app/datas/story.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:get/get.dart';

class ScriptApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = "${PY_API}script/";
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  /// Add message to story. Messages are now Object
  Future<StoryPages> addScriptToStory(
      {required String type,
      required String character,
      required String storyId,
      String? text,
      Map<String, dynamic>? image,
      String? voiceId,
      int? pageNum}) async {
    try {
      String url = '${baseUri}script';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response = await dio.post(url, data: {
        "text": text,
        "character": character,
        "type": type,
        "image": image,
        "storyId": storyId,
        "pageNum": pageNum,
      });
      final data = response.data;
      StoryPages pages = StoryPages.fromJson({
        "pageNum": data[SCRIPT_PAGE_NUM],
        "scripts": [data[SCRIPTS]]
      });
      return pages;
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }

  Future<List> updateSequence(
      {required List<Map<String, dynamic>> scripts}) async {
    try {
      String url = '${baseUri}update_sequence';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response = await dio.post(url, data: scripts);
      return response.data;
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }

  Future<Map<String, dynamic>> updateScript({required Script script}) async {
    try {
      Map<String, dynamic> updateScript = script.toJSON();
      String url = '${baseUri}script';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response = await dio.put(url, data: updateScript);
      return response.data;
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }

  Future<List<StoryPages>> deleteScript({required Script script}) async {
    try {
      String url = '${baseUri}script';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response =
          await dio.delete(url, data: {"scriptId": script.scriptId});

      List<StoryPages> newScripts = [];
      for (var script in response.data) {
        StoryPages s = StoryPages.fromJson(script);
        newScripts.add(s);
      }

      return newScripts;
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }
}
