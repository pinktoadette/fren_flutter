import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/constants/secrets.dart';

/// Sets headers
class AuthApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = PY_API;
  final myKey = MACHI_KEY;

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  Future<Dio> getDio() async {
    String token = await getFirebaseUser!.getIdToken();
    log(token);
    final dio = Dio();
    dio.options.headers['Accept'] = '*/*';
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["api-key"] = myKey;
    dio.options.headers["fb-authorization"] = token;
    dio.options.followRedirects = false;
    return dio;
  }

  Future<Map<String, dynamic>> getHeaders() async {
    String token = await getFirebaseUser!.getIdToken();
    return {"fb-authorization": token, "api-key": myKey};
  }

  Future<Dio> getAzure() async {
    String token = await getFirebaseUser!.getIdToken();
    log(token);
    final dio = Dio();
    dio.options.headers['Accept'] = '*/*';
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["api-key"] = myKey;
    return dio;
  }
}
