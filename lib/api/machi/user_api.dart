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
    final dio = await auth.getDio();
    final response = await dio.get(url);
    final getData = response.data;
    return getData.toJson();
  }

  Future<void> saveUser(Map<String, dynamic> data) async {
    try {
      String url = '${baseUri}user/create_user';
      final dio = await auth.getDio();
      await dio.post(url, data: data);
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<void> updateUser(Map<String, dynamic> data) async {
    try {
      String url = '${baseUri}user/update_user';
      final dio = await auth.getDio();
      await dio.put(url, data: data);
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}
