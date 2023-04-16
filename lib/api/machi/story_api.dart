import 'package:flutter/cupertino.dart';
import 'package:fren_app/api/machi/auth_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;

class StoryApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = PY_API;
  final BotController botControl = Get.find();
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  Future<List<dynamic>> getMyStories() async {
    try {
      String url = '${baseUri}storyboard/my_stories';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response = await dio.get(url);
      return response.data;
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }
}
