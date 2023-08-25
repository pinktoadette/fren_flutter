import 'package:flutter/cupertino.dart';
import 'package:machi_app/api/api_env.dart';
import 'package:machi_app/api/machi/auth_api.dart';
import 'package:machi_app/controller/bot_controller.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;

/// Gets announcement from admin.
class AnnouncementApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = ApiConfiguration().getApiUrl();

  final BotController botControl = Get.find(tag: 'bot');
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  Future<dynamic> getAnnounce() async {
    String url = '${baseUri}announcement/announce';
    debugPrint("Requesting URL $url");
    final response = await auth.retryGetRequest(url);
    return response.data;
  }

  /// An announcement may contain surveys.
  Future<String> responseToSurvey(
      {required String announceId, required String choiceId}) async {
    String url = '${baseUri}announcement/user_respond';
    debugPrint("Requesting URL $url");
    final dio = await auth.getDio();
    final response = await dio
        .post(url, data: {"announceId": announceId, "choiceId": choiceId});
    return response.data;
  }
}
