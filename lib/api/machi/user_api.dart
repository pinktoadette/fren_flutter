import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:fren_app/api/machi/auth_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/controller/bot_controller.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;

class BotApi {
  final _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final baseUri = 'https://machi.herokuapp.com/api/';
  final BotController botControl = Get.find();
  final auth = AuthApi();

  fire_auth.User? get getFirebaseUser => _firebaseAuth.currentUser;

  Future<dynamic> getBotPrompt(String domain, String repoId, String inputs) async {
    String url = '${baseUri}machi_bot';
    Map<String, String> data = {"domain": domain, "model": "train_data", "prompt": inputs};

    if (botControl.bot.botId == DEFAULT_BOT_ID) {
      url = '${baseUri}huggable_bot';
      data = {"domain": domain, "model": "facebook/blenderbot-400M-distill", "prompt": inputs};
    }

    //@todo need catch error
    final dio = await auth.getDio();
    final response = await dio.post(url, data: data);

    if (botControl.bot.botId == DEFAULT_BOT_ID) {
      String jsonsDataString = response.toString(); // toString of Response's body is assigned to jsonDataString
      final _data = jsonDecode(jsonsDataString);
      return _data!['generated_text'];
    }
    log (response.toString());
    return response.data;
  }

}
