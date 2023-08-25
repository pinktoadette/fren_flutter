import 'package:flutter/cupertino.dart';
import 'package:machi_app/api/api_env.dart';
import 'package:machi_app/api/machi/auth_api.dart';
import 'package:machi_app/controller/bot_controller.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;

/// Handles all searches.
class SearchApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = ApiConfiguration().getApiUrl();

  final BotController botControl = Get.find(tag: 'bot');
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  Future<List<dynamic>> searchUser(String term) async {
    String url = '${baseUri}search/user?term=$term';
    debugPrint("Requesting URL $url");
    final response = await auth.retryGetRequest(url);
    final data = response.data;
    return data;
  }

  Future<List<dynamic>> searchMachi(String term) async {
    String url = '${baseUri}search/machi?term=$term';
    debugPrint("Requesting URL $url");
    final response = await auth.retryGetRequest(url);
    final data = response.data;
    return data;
  }
}
