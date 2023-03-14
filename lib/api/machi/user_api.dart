import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:fren_app/api/machi/auth_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:fren_app/datas/user.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;

class UserApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = 'https://machi.herokuapp.com/api/';
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

  Future<User> saveUser(Map<String, dynamic> data) async {
    String url = '${baseUri}create_user';
    final dio = await auth.getDio();
    final response = await dio.post(url, data: data);
    final getData = response.data;
    return getData.toJson();
  }

}
