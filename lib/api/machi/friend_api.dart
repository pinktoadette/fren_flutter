import 'package:flutter/cupertino.dart';
import 'package:machi_app/api/machi/auth_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/bot_controller.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;

enum FriendStatus { request, active, block, unfriend }

class FriendApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = PY_API;
  final BotController botControl = Get.find(tag: 'bot');
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  Future<List<dynamic>> getOneFriend(String friendId) async {
    try {
      String url = '${baseUri}friends/get_friend';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response = await dio.get(url, data: {FB_UID: friendId});
      return response.data;
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }

  Future<String> sendRequest(String friendId) async {
    try {
      String url = '${baseUri}friends/request';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response = await dio.post(url, data: {FB_UID: friendId});
      return response.data;
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }

  Future<String> respondRequest(String friendId, FriendStatus action) async {
    try {
      String url = '${baseUri}friends/respond_request';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response =
          await dio.post(url, data: {FB_UID: friendId, FRIEND_STATUS: action});
      return response.data;
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }

  Future<List<dynamic>> getAllFriends() async {
    try {
      String url = '${baseUri}friends/get_friends';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        return response.data;
      }
      return [];
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }
}
