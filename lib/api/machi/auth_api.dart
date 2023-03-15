import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:get/get.dart';

/// Sets headers
class AuthApi {

  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = PY_API;
  final BotController botControl = Get.find();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  Future<Dio> getDio() async {
    String token = await getFirebaseUser!.getIdToken();
    log(token);
    final dio = Dio();
    dio.options.headers['Accept'] = '*/*';
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["api-key"] = "3e27dcb9-5c20-4658-abd2-fe333ae7721a";
    dio.options.headers["fb-authorization"] = token;
    dio.options.followRedirects = false;
    return dio;
  }
}