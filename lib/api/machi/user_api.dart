import 'package:flutter/cupertino.dart';
import 'package:fren_app/api/machi/auth_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/datas/user.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;

class UserApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = PY_API;
  final BotController botControl = Get.find();
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  Future<User> getUser() async {
    String url = '${baseUri}user_info';
    debugPrint("Requesting URL $url");
    final dio = await auth.getDio();
    final response = await dio.get(url);
    final getData = response.data;
    return getData.toJson();
  }

  Future<void> saveUser(Map<String, dynamic> data) async {
    try {
      String url = '${baseUri}user/create_user';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      await dio.post(url, data: data);
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<void> updateUser(Map<String, dynamic> data) async {
    try {
      String url = '${baseUri}user/update_user';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      await dio.put(url, data: data);
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  ///////// User's friend /////////
  Future<List<dynamic>> getOneFriend(String friendId) async {
    try {
      String url = '${baseUri}friends/get_friend';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response = await dio.get(url, data: {"uid": friendId});
      return response.data;
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }

  Future<List<dynamic>> sendRequest(String friendId) async {
    try {
      String url = '${baseUri}friends/request';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response = await dio.post(url, data: {"uid": friendId});
      return response.data;
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }

  Future<List<dynamic>> acceptRequest(String friendId) async {
    try {
      String url = '${baseUri}friends/get_friend';
      debugPrint("Requesting URL $url");
      final dio = await auth.getDio();
      final response = await dio.get(url, data: {"uid": friendId});
      return response.data;
    } catch (error) {
      debugPrint(error.toString());
      throw error.toString();
    }
  }
}
